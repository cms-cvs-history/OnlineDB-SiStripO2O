RunAnalyzePedNoise(char* input, char* Run, char* outdir="")
{
  if(!gROOT->LoadMacro("AnalyzePedNoise.C+"))
    AnalyzePedNoise(input,Run,outdir);
}
