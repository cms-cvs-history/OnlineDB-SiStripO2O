RunAnalyzePedNoise(char* input, char* Run, char* outdir="")
{
  gROOT->ProcessLine(".L AnalyzePedNoise.C+");
  gSystem->Load("AnalyzePedNoise_C.so");
  AnalyzePedNoise(input,Run,outdir);
}
