#include "OnlineDB/SiStripO2O/test/SiStripMonitorPedNoise.h"
#include "CalibTracker/SiStripCommon/interface/SiStripDetInfoFileReader.h"
#include "FWCore/ParameterSet/interface/FileInPath.h"

static const uint16_t _NUM_SISTRIP_SUBDET_ = 4;
std::string SubDet[_NUM_SISTRIP_SUBDET_]={"TIB","TID","TOB","TEC"};
short SubDetLayers[_NUM_SISTRIP_SUBDET_]={4, 6, 6, 18};

SiStripMonitorPedNoise::SiStripMonitorPedNoise(edm::ParameterSet const& conf): 
  conf_(conf),
  filename_(conf.getParameter<std::string>("fileName")), 
  Hlist(new TObjArray()),
  not_the_first_event(false)
{}

SiStripMonitorPedNoise::~SiStripMonitorPedNoise(){}
  
void SiStripMonitorPedNoise::analyze(const edm::Event& e, const edm::EventSetup& es) {
    
  edm::LogInfo("SiStripMonitorPedNoise") << "[SiStripMonitorPedNoise::analyse]  " << "Run " << e.id().run() << " Event " << e.id().event() << std::endl;
    
  runNb   = e.id().run();
  eventNb = e.id().event();
  std::cout << "Processing run " << runNb << " event " << eventNb << std::endl;
    
  if (not_the_first_event) 
    return;
  not_the_first_event=true;

  

  //get cabling
  es.get<SiStripDetCablingRcd>().get( SiStripDetCabling_ );

  es.get<SiStripPedestalsRcd>().get(SiStripPedestals_);
  es.get<SiStripNoisesRcd>().get(SiStripNoises_);


  fillSubDet_Layer_DetList();
    
  //Book Histos
  if(!book())
    return;

  //Fill Histos
  fillHistos();

  /////////////

  
  std::vector<uint32_t> det_ids;
  SiStripDetCabling_->addActiveDetectorsRawIds(det_ids);
  if ( det_ids.empty() ) {
    edm::LogWarning("SiStripMonitorPedNoise")
      << "detids vetor empty";
  }  
  edm::LogInfo("SiStripMonitorPedNoise") << " Cabling Found " << det_ids.size() << " active DetIds";
  if (edm::isDebugEnabled()){
    // Iterate through active DetIds
    std::vector<uint32_t>::const_iterator det_id = det_ids.begin();
    for ( ; det_id != det_ids.end(); det_id++ ) {
      edm::LogInfo("SiStripMonitorPedNoise") << " detid " << *det_id << std::endl;
    }    
  }


  //COPY NOISE
  std::vector<uint32_t> ndetid;
  SiStripNoises_->getDetIds(ndetid);
  edm::LogInfo("SiStripMonitorPedNoise") << " Noise Found " << ndetid.size() << " DetIds";
  for (size_t id=0;id<ndetid.size();id++){
    SiStripNoises::Range range=SiStripNoises_->getRange(ndetid[id]);

    if (edm::isDebugEnabled()){
      int strip=0;
      LogTrace("SiStripMonitorPedNoise")  << "NOISE detid " << ndetid[id] << " \t"
			      << " strip " << strip << " \t"
			      << SiStripNoises_->getNoise(strip,range)     << " \t" 
			      << SiStripNoises_->getDisable(strip,range)   << " \t" 
			      << std::endl; 	    
    } 
  }

  //COPY PED
  std::vector<uint32_t> pdetid;
  SiStripPedestals_->getDetIds(pdetid);
  edm::LogInfo("SiStripMonitorPedNoise") << " Peds Found " << pdetid.size() << " DetIds";
  for (size_t id=0;id<pdetid.size();id++){
    SiStripPedestals::Range range=SiStripPedestals_->getRange(pdetid[id]);

    if (edm::isDebugEnabled()){
      int strip=0;
      LogTrace("SiStripMonitorPedNoise")  << "PED detid " << pdetid[id] << " \t"
			      << " strip " << strip << " \t"
			      << SiStripPedestals_->getPed   (strip,range)   << " \t" 
			      << SiStripPedestals_->getLowTh (strip,range)   << " \t" 
			      << SiStripPedestals_->getHighTh(strip,range)   << " \t" 
			      << std::endl; 	    
    } 
  }  

  /////////////////

  
  fFile->ls();

  for (int ih=0; ih<Hlist->GetEntries();ih++){
    if (dynamic_cast<TH1F*>((*Hlist)[ih]) !=NULL){
      if (dynamic_cast<TH1F*>((*Hlist)[ih])->GetEntries() == 0){
	delete (*Hlist)[ih];
	Hlist->RemoveAt(ih);
      }
    } else if (dynamic_cast<TProfile*>((*Hlist)[ih]) !=NULL){
      if (dynamic_cast<TProfile*>((*Hlist)[ih])->GetEntries() == 0){
	delete (*Hlist)[ih];
	Hlist->RemoveAt(ih);
      }
    }
  }

  
  fFile->Write();
  fFile->Close();
  
}

void SiStripMonitorPedNoise::fillHistos(){

  std::vector<uint32_t>::iterator detid_iter;
  std::vector<uint32_t> vdetid;
  SiStripNoises_->getDetIds(vdetid);
  std::vector<uint32_t>::iterator olddetid_iter=vdetid.begin();

  char layer[128];
  std::string name;
  std::string subName;

  int pos=0;
  //loop on subdets
  for (int i=0;i<_NUM_SISTRIP_SUBDET_;++i){
    //loop on layers
    for(int ilayer=0;ilayer<SubDetLayers[i];++ilayer){
      if (i==0 || i==2)
	sprintf(layer,"_Layer_%d",ilayer+1);
      else if (i==1)
	sprintf(layer,"_Disc_%d_%d",ilayer/3+1,ilayer%3+1);
      else
	sprintf(layer,"_Wheel_%d_%d",ilayer/9+1,ilayer%9+1);

      subName=SubDet[i]+layer;
      
      pos++;

      //skip empty containers
      if (_SubDet_Layer_DetList[i][ilayer].size()==0){
	std::cout << subName << " is empty " << std::endl;
	continue;
      }


      name="DBNoiseHisto_"+subName;      
      TH1F* hn= (TH1F*) Hlist->FindObject(name.c_str());

      name="DBNoiseRatioProfile_"+subName;      
      TH1F* prn= (TH1F*) Hlist->FindObject(name.c_str());

      name="DBNoiseProfile_"+subName;      
      TH1F* pn= (TH1F*) Hlist->FindObject(name.c_str());

      name="DBPedProfile_"+subName;      
      TH1F* pp= (TH1F*) Hlist->FindObject(name.c_str());

      name="NDetModules";
      TH1F* num= (TH1F*) Hlist->FindObject(name.c_str());

      //Loop on dets
      int startbin=0;
      for (std::map<uint32_t,short>::const_iterator iter=_SubDet_Layer_DetList[i][ilayer].begin();iter!=_SubDet_Layer_DetList[i][ilayer].end();++iter){
	uint32_t detid=iter->first;
	
	if (detid < 1 || detid == 4294967295){
	  std::cout << "[SiStripMonitorPedNoise::fillHistos] invalid detid " << detid << std::endl;
	  continue;
	} 		

	detid_iter=std::lower_bound(vdetid.begin(),vdetid.end(),detid);
	if(detid_iter!=vdetid.end()){
	  if (*detid_iter==detid){
	    Ndets_SubDet_Layer[i][ilayer]++;
	    olddetid_iter=detid_iter;

	    char cdetid[64];
	    sprintf(cdetid,"%d",detid);
	    pn->GetXaxis()->SetBinLabel(startbin+50,cdetid);
	    pp->GetXaxis()->SetBinLabel(startbin+50,cdetid);

	    SiStripNoises::Range range=SiStripNoises_->getRange(detid);
	    SiStripPedestals::Range range_p=SiStripPedestals_->getRange(detid);

	    for(int it=0;it<range.second-range.first;++it){
	      startbin++;

	      hn->Fill(SiStripNoises_->getNoise(it,range));   
	      pn->SetBinContent(startbin,SiStripNoises_->getNoise(it,range));
	      pp->SetBinContent(startbin,SiStripPedestals_->getPed(it,range_p));

	      //	      std::cout << "Noise " << detid << " " << it  << " " << startbin+it << " " << SiStripNoises_->getNoise(it,range) << std::endl;

	      if (it%128==0){
		sprintf(cdetid,"%d",it);
		pn->GetXaxis()->SetBinLabel(startbin,cdetid);
		pp->GetXaxis()->SetBinLabel(startbin,cdetid);
	      }
	    }

	  }else{
	  startbin+=iter->second;
	  }
	}
      }
      num->Fill(pos,Ndets_SubDet_Layer[i][ilayer]);
    }
  }
}

bool SiStripMonitorPedNoise::book(){
  fFile = new TFile(filename_.c_str(),"UPDATE");
  
  //Verify dir for this run doesn't exist
  char cRun[64];
  sprintf(cRun,"%d",runNb);
  if (fFile->Get(cRun) != 0){
    std::cout << "In file " << filename_ << " the dir related to Run " << runNb << " already exists. EXIT " << std::endl;
    return false;
  }
  
  TDirectory * newDir;
  newDir=fFile->mkdir(cRun);

  newDir->cd();
  TH1F* num=new TH1F("NDetModules","NDetModules",34,0.5,34.5);
  Hlist->Add(num);

  //Create Histograms
  std::string name;
  char layer[128];

  edm::ParameterSet Parameters =  conf_.getParameter<edm::ParameterSet>("TH1Noises");
  
  int pos=0;
  for (int i=0;i<_NUM_SISTRIP_SUBDET_;++i){
    std::string subDir=SubDet[i];
    //std::cout << "file"<< std::endl;
    //gDirectory->ls();
    newDir->cd();
    //std::cout << "newDir"<< std::endl;
    //gDirectory->ls();
    TDirectory *newSubDir=newDir->mkdir(subDir.c_str());    
    newSubDir->cd();
    //std::cout << "subdir"<< std::endl;
    //gDirectory->ls();

    //loop on layers
    for(int ilayer=0;ilayer<SubDetLayers[i];++ilayer){
      //skip empty containers
      Ndets_SubDet_Layer[i][ilayer]=0;
      if (_SubDet_Layer_DetList[i][ilayer].size()==0)
	continue;

      if (i==0 || i==2)
	sprintf(layer,"_Layer_%d",ilayer+1);
      else if (i==1)
	sprintf(layer,"_Disc_%d_%d",ilayer/3+1,ilayer%3+1);
      else
	sprintf(layer,"_Wheel_%d_%d",ilayer/9+1,ilayer%9+1);

      pos++;
      num->GetXaxis()->SetBinLabel(pos,(SubDet[i]+layer).c_str());

      //Create Histograms
      name="DBNoiseHisto_"+SubDet[i]+layer;
      TH1F* hn = new TH1F(name.c_str(),name.c_str(),Parameters.getParameter<int32_t>("Nbinx"),
			  Parameters.getParameter<double>("xmin"),
			  Parameters.getParameter<double>("xmax"));
      Hlist->Add(hn);	
      std::cout << "Created histogram " << name << std::endl;

      int nstrips=0;
      //Create profiles
      for (std::map<uint32_t,short>::const_iterator iter=_SubDet_Layer_DetList[i][ilayer].begin();iter!=_SubDet_Layer_DetList[i][ilayer].end();++iter){
	nstrips+=iter->second;
      }
      name="DBNoiseProfile_"+SubDet[i]+layer;
      TH1F* pn = new TH1F(name.c_str(),name.c_str(),nstrips,-0.5,nstrips-0.5);
      Hlist->Add(pn);	
      std::cout << "Created histogram " << name << std::endl;

      name="DBNoiseRatioProfile_"+SubDet[i]+layer;
      TH1F* prn = new TH1F(name.c_str(),name.c_str(),nstrips,-0.5,nstrips-0.5);
      Hlist->Add(prn);	
      std::cout << "Created histogram " << name << std::endl;

      name="DBPedProfile_"+SubDet[i]+layer;
      TH1F* pp = new TH1F(name.c_str(),name.c_str(),nstrips,-0.5,nstrips-0.5);
      Hlist->Add(pp);	
      std::cout << "Created histogram " << name << std::endl;      
    }
  }
  return true;
}

void SiStripMonitorPedNoise::fillSubDet_Layer_DetList(){

  SiStripDetInfoFileReader reader(edm::FileInPath(std::string("CalibTracker/SiStripCommon/data/SiStripDetInfo.dat") ).fullPath());
  const std::vector<uint32_t> DetIds = reader.getAllDetIds();
  
  std::vector<uint32_t>::const_iterator it=DetIds.begin();
  for(;it!=DetIds.end();++it){
    uint32_t detid=*it;
    
    short Nstrips = reader.getNumberOfApvsAndStripLength(detid).first*128;
  
    SiStripDetId a(detid);
    if ( a.subdetId() == 3 ){
      TIBDetId b(detid);
        _SubDet_Layer_DetList[0][b.layer()-1].insert(std::pair<uint32_t,short>(detid,Nstrips));
    } else if ( a.subdetId() == 4 ) {
      TIDDetId b(detid);
      _SubDet_Layer_DetList[1][b.side()==1?b.wheel()-1:b.wheel()+2].insert(std::pair<uint32_t,short>(detid,Nstrips));
    } else if ( a.subdetId() == 5 ) {
      TOBDetId b(detid);
      _SubDet_Layer_DetList[2][b.layer()-1].insert(std::pair<uint32_t,short>(detid,Nstrips));
    } else if ( a.subdetId() == 6 ) {
      TECDetId b(detid);
      _SubDet_Layer_DetList[3][b.side()==1?b.wheel()-1:b.wheel()+8].insert(std::pair<uint32_t,short>(detid,Nstrips));
    }     
  }
}
    
