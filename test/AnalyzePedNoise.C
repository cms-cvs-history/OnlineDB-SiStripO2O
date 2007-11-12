#include <iostream>
#include <stdio.h>
#include <string.h>
#include <sstream>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include "TFile.h"
#include "TH1F.h"
#include "TH2F.h"
#include "TKey.h"
#include "TObject.h"
#include "TDirectory.h"
#include "TMath.h"
#include "TCanvas.h"
#include "TStyle.h"
#include "TGraph.h"
#include "TGraphErrors.h"
#include "TMultiGraph.h"
#include "TLegend.h"
#include "TAxis.h"
#include "TGaxis.h"

char * Mask;
TFile *f;
TCanvas* C;
std::string SubDet[4]={"TIB" , "TID" , "TOB" , "TEC"};
struct Meas{
  int iRun;
  float mean;
  float rms;
};


void GetNumDetectedModules(char* RunDir){
  std::string path=std::string(RunDir) +"/NDetModules";
  TH1F* num=(TH1F*) f->Get(path.c_str());

  if(num==NULL)
    return;

  std::cout << "$$$ " << RunDir ;
  for(int i=0;i<num->GetNbinsX()+1;++i){
    if (num->GetBinContent(i))
      std::cout << " \t\t " << num->GetXaxis()->GetBinLabel(i) << " \t\t " << num->GetBinContent(i);
  }
  std::cout << std::endl;
}


void GetNoiseHisto(char* RunDir,char* outdir){
  std::string append="";
  for (int iSubDet=0;iSubDet<4;++iSubDet){
    C->Clear();
    C->Divide(2,3);
    C->Update();
    std::string path=std::string(RunDir)+"/"+SubDet[iSubDet];
    f->cd();f->cd(path.c_str());

    int i=0;
    TIter nextkey(gDirectory->GetListOfKeys());
    TObject *obj;
    TKey *key;
    while (key = (TKey*)nextkey()) {
      obj = key->ReadObj();
      
      if ( obj->IsA()->InheritsFrom( "TH1" ) ) {
	TH1F* h = (TH1F*)key->ReadObj();
	if (!h->GetEntries())
	  continue;
	if (strstr(obj->GetTitle(),"Histo")==NULL)
	  continue;
    
	//std::cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==6){
	  C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBNoiseHisto_"+SubDet[iSubDet]+append+".png").c_str());
	  i=0;
	  append="_bis";
	}
      }
    }
    if(i)
      C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBNoiseHisto_"+SubDet[iSubDet]+append+".png").c_str());
  }
}

void GetNoiseProfile(char* RunDir, char* outdir){
  std::string append="_bis";
  for (int iSubDet=0;iSubDet<4;++iSubDet){
    C->Clear();
    C->Divide(2,3);
    C->Update();
    std::string path=std::string(RunDir)+"/"+SubDet[iSubDet];
    f->cd();f->cd(path.c_str());

    int i=0;
    TIter nextkey(gDirectory->GetListOfKeys());
    TObject *obj;
    TKey *key;
    while (key = (TKey*)nextkey()) {
      obj = key->ReadObj();
      
      if ( obj->IsA()->InheritsFrom( "TH1" ) ) {
	TH1F* h = (TH1F*)key->ReadObj();
	if (!h->GetEntries())
	  continue;
	if (strstr(obj->GetTitle(),"NoiseProfile")==NULL)
	  continue;
    
	//std::cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==7){
	  C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBNoiseProfile_"+SubDet[iSubDet]+append+".png").c_str());
	  i=0;
	}
      }
    }
    if(i)
      C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBNoiseProfile_"+SubDet[iSubDet]+".png").c_str());
  }
}

void GetPedProfile(char* RunDir, char* outdir){
  std::string append="_bis";
  for (int iSubDet=0;iSubDet<4;++iSubDet){
    C->Clear();
    C->Divide(2,3);
    C->Update();
    std::string path=std::string(RunDir)+"/"+SubDet[iSubDet];
    f->cd();f->cd(path.c_str());

    int i=0;
    TIter nextkey(gDirectory->GetListOfKeys());
    TObject *obj;
    TKey *key;
    while (key = (TKey*)nextkey()) {
      obj = key->ReadObj();
      
      if ( obj->IsA()->InheritsFrom( "TH1" ) ) {
	TH1F* h = (TH1F*)key->ReadObj();
	if (!h->GetEntries())
	  continue;
	if (strstr(obj->GetTitle(),"PedProfile")==NULL)
	  continue;
    
	//std::cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==7){
	  C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBPedProfile_"+SubDet[iSubDet]+append+".png").c_str());
	  i==0;
	}
      }
    }
    if(i)
      C->Print(std::string(std::string(outdir)+"/Run_"+std::string(RunDir)+"_DBPedProfile_"+SubDet[iSubDet]+".png").c_str());
  }
}


void MakeTrend(char* outdir){
    
  //Count Runs
  Meas Meas_;
  
  std::vector<std::string> RunList;
  std::vector<int> RunListN;
  int NRuns=0;

  TIter nextkey(gDirectory->GetListOfKeys());
  TObject *obj;
  TKey *key;
  while (key = (TKey*)nextkey()) {
    obj = key->ReadObj();
    if ( obj->IsA()->InheritsFrom( "TDirectory" ) ) {
      RunListN.push_back(atoi(obj->GetTitle()));
      std::cout << NRuns << " Run " << RunListN.back() << endl;
      NRuns++;
    }
  }
  std::sort(RunListN.begin(),RunListN.end());

  char pch[128];
  for (int i=0;i<RunListN.size();++i){
    sprintf(pch,"%d",RunListN[i]);
    RunList.push_back(pch);
    std::cout << RunListN[i] << " " << RunList[i] << endl;
  }

  f->cd();
  
  std::cout << "NRuns " << NRuns << endl;
  

  float lxl,lyl,lxr,lyr;
  lxl=.2;
  lyl=.9;
  lxr=.4;
  lyr=.7;

  for (int iSubDet=0;iSubDet<4;++iSubDet){

    std::map<std::string,std::vector<Meas> > mapLayerData;
    int count=0;
    for(size_t i=0;i<RunList.size();++i){
      std::string path=RunList[i]+"/"+SubDet[iSubDet];
      f->cd();f->cd(path.c_str());
      //std::cout << path << endl;

      std::cout << "$$$ " << RunList[i];      
      TIter nextkey(gDirectory->GetListOfKeys());
      TObject *obj;
      TKey *key;
      while (key = (TKey*)nextkey()) {
	
	if (strstr(key->GetTitle(),"Histo")==NULL)
	  continue;	
	obj = key->ReadObj();
	
	if ( obj->IsA()->InheritsFrom( "TH1" ) ) {
	  TH1F* h = (TH1F*)obj;
	  if (!h->GetEntries())
	    continue;
	  	  
	  std::string thisHisto=TString(obj->GetTitle()).ReplaceAll("DBNoiseHisto_","").Data();
	  Meas_.iRun=count;
	  Meas_.mean=h->GetMean();
	  Meas_.rms=h->GetRMS();
	  //std::cout << "\t\t " << thisHisto << " " << count << " " << Meas_.mean << " " << Meas_.rms << endl;


	  std::cout << " \t\t " << thisHisto << " \t\t " << h->GetEntries();
        
	  mapLayerData[thisHisto].push_back(Meas_);
	}
      }
      count++;
      std::cout<< endl;
    }

    const size_t m = mapLayerData.size();
    if(!m)
      continue;
    std::cout<<"CREATE MULTIGRAPH"<< std::endl;

    TH1F baseHisto("base","",NRuns,-0.5,NRuns-0.5);
    std::vector<TH1F *> gr[4];

    TLegend *tleg[4]={new TLegend(lxl,lyl,lxr,lyr),new TLegend(lxl,lyl,lxr,lyr),new TLegend(lxl,lyl,lxr,lyr),new TLegend(lxl,lyl,lxr,lyr)};

    std::cout << "Looking at Subdet " << SubDet[iSubDet] << endl;
    C->Clear();
    
    if (iSubDet<3)
      C->Divide(1);
    else
      C->Divide(2,2);
    C->Update();

    int n = RunList.size();
    std::cout << "N point " << n << endl;
    int jLayer=0;
    size_t maxPads=0;
    
    for (std::map<std::string,std::vector<Meas> >::const_iterator iter=mapLayerData.begin();iter!=mapLayerData.end();++iter){
      //      std::cout << " ----------- " << endl;
      for (std::vector<Meas>::const_iterator jter=iter->second.begin(); jter!=iter->second.end();++jter){
	if (jter==iter->second.begin()){
	  maxPads=(jLayer)/6;
	  gr[maxPads].push_back((TH1F*) baseHisto.Clone(iter->first.c_str() ) );
	  gr[maxPads].back()->SetMarkerStyle(24+(int) jLayer/6);
	  gr[maxPads].back()->SetMarkerColor(jLayer%6+1);
	  tleg[maxPads]->AddEntry(gr[maxPads].back(),iter->first.c_str(),"p");
	  //std::cout << "maxPads " << maxPads << endl;
	}
	double val=jter->mean;
	double rms=jter->rms;
	//	std::cout << iter->first << " " << jter->iRun << " " << val << endl;
	gr[maxPads].back()->SetBinContent(jter->iRun+1,val<10?val:10);
	gr[maxPads].back()->SetBinError(jter->iRun+1,0,rms<10?rms:10);
      }
      jLayer++;
    }
    
    for (int iPad=0;iPad<=maxPads;++iPad){
      C->cd(iPad+1);
      for(int ih=0;ih<gr[iPad].size();++ih){
	gr[iPad][ih]->SetMaximum(10);
	gr[iPad][ih]->Draw(ih==0?"E1":"sameE1");
      }
      
      TAxis* axis=gr[iPad][0]->GetXaxis();
      axis->SetTitle("Run");
      axis->SetTitleOffset(2.0);
      gr[iPad][0]->GetYaxis()->SetTitle("Mean");
      tleg[iPad]->SetFillStyle(0);
      tleg[iPad]->Draw();
      
      for(size_t i=0;i<RunList.size();++i){
	if(i%3==0 || RunList.size()<10){
	  axis->SetBinLabel(i+1,RunList[i].c_str());
	}
      }
      gPad->SetGridx();
    }
    C->Update();    
    C->Print(std::string(std::string(outdir)+"_"+SubDet[iSubDet]+".png").c_str());
    C->Print(std::string(std::string(outdir)+"_"+SubDet[iSubDet]+".eps").c_str());
  }
}

void AnalyzePedNoise(char *input, char* RunDir, char* outdir=""){
  gStyle->SetNdivisions(510);
  gStyle->SetOptStat(0);

  std::cout << "[AnalyzePedNoise] input " << input << " Run " << RunDir << " output " << outdir << endl;
  f=new TFile(input,"READ"); 

  C = new TCanvas();

  if (std::string(RunDir)!="-1"){
    GetNumDetectedModules(RunDir);
    GetNoiseHisto(RunDir,outdir);
    //  GetNoiseProfile(RunDir);
    //  GetPedProfile(RunDir);
  }else{
    MakeTrend(outdir);
  }
 
}
