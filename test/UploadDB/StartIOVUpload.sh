#!/bin/sh


function doO2O(){

grep TIF2 log/O2ORuns.txt | while read line
  do

  run=`echo $line | cut -f 1 -d " "`
  partition=`echo $line | cut -f 2 -d " " `
  Mfedv=`echo $line | cut -f 4 -d " " | cut -f 1 -d "."`
  mfedv=`echo $line | cut -f 4 -d " " | cut -f 2 -d "."`

  echo -e "\n\n\n"
  echo .... analyzing run $run $partition $Mfedv $mfedv

  cat template_sistripo2o.cfg | sed -e "s@insert_Run@$run@g" -e "s@insert_ConfigDbPartition@$partition@g" -e "s@insert_fedmajor@$Mfedv@g" -e "s@insert_fedminor@$mfedv@g" -e "s@insert_connect_string@${connectstring}@g" -e "s@insert_authPath@${authPath}@g" -e "s@insert_pedestals_tag@$tagp@g" -e "s@insert_noise_tag@$tagn@g" -e "s@insert_cabling_tag@$tagc@g" > log/SiStripO2O_$run.cfg

  echo "cmsRun  log/SiStripO2O_$run.cfg > log/Log_$run.log"
  cmsRun  log/SiStripO2O_$run.cfg > log/Log_$run.log

done
}


############
##  MAIN  ##
############


#-------------------------------------------------------

connectstringA="sqlite_file:dbfile.db"
connectstringB="oracle://cms_orcoff_int2r/CMS_COND_STRIP"
connectstringC="oracle://orcon/CMS_COND_STRIP"

connectstring=${connectstringC}

USER=CMS_COND_STRIP
PASSWD=SSWDC3MCAI8HQHTC
#authPath=/afs/cern.ch/cms/DB/conddb
authPath=/afs/cern.ch/user/x/xiezhen/auth/orconowner

tagn=SiStripNoise_TIF_20X
tagp=SiStripPedestals_TIF_20X
tagc=SiStripFedCabling_TIF_20X

#-------------------------------------------------------

scriptDir=`dirname $0`
cd $scriptDir

eval `scramv1 runtime -sh`

export TNS_ADMIN=/afs/cern.ch/project/oracle/admin


rm dbfile.db
#cmscond_bootstrap_detector.pl --offline_connect sqlite_file:dbfile.db --auth /afs/cern.ch/cms/DB/conddb/authentication.xml STRIP

workdir=`pwd`
if [ ! -e $CMSSW_BASE/src/CondFormats/SiStripObjects/xml ]; then
    cd $CMSSW_BASE/src 
    cvs co CondFormats/SiStripObjects/xml 
    cd $workdir 
fi

if [ `echo ${connectstring} | grep -c sqlite` -ne 0 ]  || [[ `echo ${connectstring} | grep -c oracle` -ne 0  &&  "c$1" == "cforce" ]] ; then
    
    echo -e "\n-----------\nCreating tables for db ${connectstring} \n-----------\n"
    
    IsSqlite=1
    rm `echo ${connectstring} | sed -e "s@sqlite_file:@@"`

    #cmscond_bootstrap_detector.pl --offline_connect ${connectstring} --auth /afs/cern.ch/cms/DB/conddb/authentication.xml STRIP
    for obj in `ls $CMSSW_BASE/src/CondFormats/SiStripObjects/xml/*xml`
      do
      echo -e  "\npool_build_object_relational_mapping -f $obj   -d CondFormatsSiStripObjects -c ${connectstring}\n"
      pool_build_object_relational_mapping -f $obj   -d CondFormatsSiStripObjects -c ${connectstring} -u $USER -p $PASSWD

    done
fi



mkdir log
echo -e "\n---------------------------------\n"
echo 'wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt'
wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt

echo "extracting o2o runs"
echo 
cat log/AllRuns.txt | sort -n -k 1 | awk -F"\t" 'BEGIN{fedv=0} {if (NR>1 && ( $3 == "LATENCY" || $3 == "PHYSIC" || $3 == "PHYSIC_ZERO_SUPPRESSION" ) && fedv != $13) {fedv=$13;  a=sprintf("%d \t %30s \t  %30s \t %6.2f \t %s",$1,$2,$3,$13,$15); print a} }' | sort -n -k 1 > log/O2ORuns.txt


doO2O


cd -





