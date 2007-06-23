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

  std::cout << "$$$ " << RunDir ;
  for(int i=0;i<num->GetNbinsX()+1;++i){
    if (num->GetBinContent(i))
      std::cout << " \t\t " << num->GetXaxis()->GetBinLabel(i) << " \t\t " << num->GetBinContent(i);
  }
  std::cout << std::endl;
}


void GetNoiseHisto(char* RunDir){
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
	if (strstr(obj->GetTitle(),"Histo")==NULL)
	  continue;
    
	//cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==5){
	  C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBNoiseHisto_"+SubDet[iSubDet]+append+".png").c_str());
	  i=0;
	}
      }
    }
    if(i)
      C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBNoiseHisto_"+SubDet[iSubDet]+".png").c_str());
  }
}

void GetNoiseProfile(char* RunDir){
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
    
	//cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==7){
	  C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBNoiseProfile_"+SubDet[iSubDet]+append+".png").c_str());
	  i=0;
	}
      }
    }
    if(i)
      C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBNoiseProfile_"+SubDet[iSubDet]+".png").c_str());
  }
}

void GetPedProfile(char* RunDir){
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
    
	//cout << obj->GetTitle() << endl;

	C->cd(++i)->SetLogy();
	h->Draw();	
	if(i==7){
	  C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBPedProfile_"+SubDet[iSubDet]+append+".png").c_str());
	  i==0;
	}
      }
    }
    if(i)
      C->Print(std::string("IMG/Run_"+std::string(RunDir)+"_DBPedProfile_"+SubDet[iSubDet]+".png").c_str());
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
      RunList.push_back(obj->GetTitle());
      RunListN.push_back(atoi(obj->GetTitle()));
      NRuns++;
    }
  }
  f->cd();
  
  cout << "NRuns" << NRuns << endl;

  std::vector<TGraphErrors *> gr[4];
  TMultiGraph *mg[4];
  TLegend *tleg[4];
  C->Clear();
  C->Divide(2,2);

  for (int iSubDet=0;iSubDet<4;++iSubDet){
    cout << "Looking at Subdet " << SubDet[iSubDet] << endl;

    std::map<std::string,std::vector<Meas> > mapLayerData;

    C->cd(iSubDet+1);
    int count=0;
    for(size_t i=0;i<RunList.size();++i){
      std::string path=RunList[i]+"/"+SubDet[iSubDet];
      f->cd();f->cd(path.c_str());
      //cout << path << endl;

      
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
	  mapLayerData[thisHisto].push_back(Meas_);
	}
      }
      count++;
    }

    const size_t m = mapLayerData.size();
    if(!m)
      continue;
    std::cout<<"CREATE MULTIGRAPH"<< std::endl;

    int n = count;
    mg[iSubDet] = new TMultiGraph();
    tleg[iSubDet] = new TLegend(0.9,1.,1.,0.80);
    int j=0;
    for (std::map<std::string,std::vector<Meas> >::const_iterator iter=mapLayerData.begin();iter!=mapLayerData.end();++iter){
      for (size_t i=0;i<n;++i) {
       	if (!i){
	  gr[iSubDet].push_back(new TGraphErrors(n));
	  gr[iSubDet][j]->SetMarkerStyle(20+j);
	  gr[iSubDet][j]->SetMarkerColor(j+1);
	  mg[iSubDet]->Add(gr[iSubDet][j],"p");
	  tleg[iSubDet]->AddEntry(gr[iSubDet][j],iter->first.c_str(),"p");
	}
	gr[iSubDet][j]->SetPoint(i,iter->second[i].iRun,iter->second[i].mean);
	gr[iSubDet][j]->SetPointError(i,0,iter->second[i].rms);
      }
      j++;
    }
    mg[iSubDet]->Draw("a");
    TAxis* axis=mg[iSubDet]->GetXaxis();
    axis->SetTitle("Run");
    
    for(size_t i=0;i<RunList.size();++i){
      if(i%2)
	axis->SetBinLabel(axis->FindBin(i),RunList[i].c_str());
    }
    mg[iSubDet]->GetYaxis()->SetTitle("Mean");
    tleg[iSubDet]->Draw();
    gPad->Update();
  }
  C->Print(std::string(std::string(outdir)+".png").c_str());
  C->Print(std::string(std::string(outdir)+".eps").c_str());
}

void AnalyzePedNoise(char *input, char* RunDir, char* outdir=""){
  
  f=new TFile(input,"READ"); 

  C = new TCanvas();

  if (std::string(RunDir)!="-1"){
    GetNumDetectedModules(RunDir);
    GetNoiseHisto(RunDir);
    //  GetNoiseProfile(RunDir);
    //  GetPedProfile(RunDir);
  }else{
    MakeTrend(outdir);
  }
 
}
