#ifndef SiStripMonitorPedNoise_h
#define SiStripMonitorPedNoise_h

#include "FWCore/Utilities/interface/Exception.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/Event.h"
#include "DataFormats/Common/interface/Handle.h"
#include "FWCore/Framework/interface/EventSetup.h"
#include "FWCore/Framework/interface/ESHandle.h"
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/MakerMacros.h" 
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "FWCore/MessageLogger/interface/MessageLogger.h"

//needed for the geometry:
#include "DataFormats/DetId/interface/DetId.h"
#include "DataFormats/SiStripDetId/interface/StripSubdetector.h"
#include "DataFormats/SiStripDetId/interface/TECDetId.h"
#include "DataFormats/SiStripDetId/interface/TIBDetId.h"
#include "DataFormats/SiStripDetId/interface/TIDDetId.h"
#include "DataFormats/SiStripDetId/interface/TOBDetId.h"

#include "CondFormats/SiStripObjects/interface/SiStripPedestals.h"
#include "CondFormats/SiStripObjects/interface/SiStripNoises.h"
#include "CondFormats/DataRecord/interface/SiStripPedestalsRcd.h"
#include "CondFormats/DataRecord/interface/SiStripNoisesRcd.h"

#include "CalibTracker/Records/interface/SiStripDetCablingRcd.h"
#include "CalibFormats/SiStripObjects/interface/SiStripDetCabling.h"

#include "TROOT.h"
#include "TFile.h"
#include "TTree.h"
#include "TBranch.h"
#include "TH1F.h"
#include "TH2F.h"
#include "TProfile.h"
#include "TString.h"
#include "TObjArray.h"
#include "TCanvas.h"
#include "TPostScript.h"


#include "boost/cstdint.hpp"
#include "vector"
#include <memory>
#include <string>
#include <iostream>

class SiStripMonitorPedNoise : public edm::EDAnalyzer
{
 public:
      
  SiStripMonitorPedNoise(const edm::ParameterSet& conf);
  
  ~SiStripMonitorPedNoise();
      
  void analyze(const edm::Event& e, const edm::EventSetup& c);
  
 private:

  void fillSubDet_Layer_DetList();
  bool book();
  void fillHistos();
  
  edm::ParameterSet conf_;
  edm::ESHandle<SiStripDetCabling> SiStripDetCabling_;
  edm::ESHandle<SiStripPedestals> SiStripPedestals_;
  edm::ESHandle<SiStripNoises> SiStripNoises_;
      
  std::map<uint32_t,short> _SubDet_Layer_DetList[4][18];
  int Ndets_SubDet_Layer[4][18];
  std::string filename_;

  TFile* fFile;
  TObjArray* Hlist;

  int runNb;
  int eventNb;

  bool not_the_first_event;
};
#endif
