mkdir log
echo 'wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt'

wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt

echo "extracting o2o runs"
echo 
cat log/AllRuns.txt | sort -n -k 1 | awk -F"\t" 'BEGIN{fedv=0} {if (NR>1 && ( $3 == "LATENCY" || $3 == "PHYSIC" || $3 == "PHYSIC_ZERO_SUPPRESSION" ) && fedv != $13) {fedv=$13;  a=sprintf("%d \t %30s \t  %30s \t %6.2f \t %s",$1,$2,$3,$13,$15); print a} }' | sort -n -k 1 >! log/O2ORuns.txt
