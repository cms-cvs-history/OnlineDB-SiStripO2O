#!/bin/bash

cd /raid/cmssw/Development/O2O/CMSSW_2_0_4/src/OnlineDB/SiStripO2O/test/P5
source /nfshome0/cmssw2/scripts/setup.sh
eval `scramv1 runtime -sh`

preTag=test5
postTag=TKCC_20X
pedestalsTag=${preTag}_SiStripPedestals_${postTag}
noiseTag=${preTag}_SiStripNoise_${postTag}
cabTag=${preTag}_SiStripFedCabling_${postTag}
authPath=/nfshome0/xiezhen/conddb/
connectString="oracle://cms_orcon_prod/CMS_COND_20X_STRIP"
storeFile="/raid/cmssw/Development/O2O/store/doneRuns_${preTag}_${postTag}"
doExit="false"

touch $storeFile

log=log_at_P5
rm -rf $log
mkdir $log

eval `scramv1 runtime -sh`

export TNS_ADMIN=/nfshome0/xiezhen/conddb/

#sqlplus -S -M "HTML ON " cms_trk_tkcc/tkcc2008@cms_omds_lb < OMDSQuery.sql

sqlplus -S -M "HTML ON " cms_trk_tkcc/tkcc2008@cms_omds_lb < OMDSQuery.sql | awk 'BEGIN{newline=0; stringa=""} $0~/<*th.*>/{newline=0} $0~/<tr>/{newline=1;if(stringa!="") print stringa; stringa=""} $0~/<\/tr>/{newline=0;} $0!~/<?td.*>/{if(newline && $0!="<tr>"){stringa=sprintf("%s %s",stringa,$0)}}' | sort -n| while read line;
  do
  vec=($line)
  #echo ${vec[@]}
  runNb=${vec[0]}
    #echo ${vec[1]}
  partition=${vec[2]}
  fecV=${vec[3]}
  fedV=${vec[4]}
  cabV=${vec[5]}
    
  # echo $runNb $partition $fecV $fedV $cabV

  fedVMaj=`echo $fedV | cut -d "." -f1`
  fedVmin=`echo $fedV | cut -d "." -f2`

  fecVMaj=`echo $fecV | cut -d "." -f1`
  fecVmin=`echo $fecV | cut -d "." -f2`

  cabVMaj=`echo $cabV | cut -d "." -f1`
  cabVmin=`echo $cabV | cut -d "." -f2`
 
  runString="$runNb $partition $cabV $fedV"
  echo -n "$runString  --  "
  if grep -q "$runString" $storeFile ; then
      echo O2O transfer already performed or not necessary
  else
      # O2O not done, let's check if it is necessary
      if tail -n1 $storeFile | grep -qe "\([0-9]*\) $partition $cabV $fedV" ; then
	  echo Fed and partition not changed since last IOV was opened. O2O Not necessary
	  echo $runString >> $storeFile
      else
	  echo Performing O2O...
	  cat template_sistripo2o.cfg | sed -e "s@insert_Run@$runNb@g" -e "s@insert_ConfigDbPartition@$partition@g" -e "s@insert_cabmajor@$cabVMaj@g" -e "s@insert_cabminor@$cabVmin@g" -e "s@insert_fedmajor@$fedVMaj@g" -e "s@insert_fedminor@$fedVmin@g" -e "s@insert_fecmajor@$fecVMaj@g" -e "s@insert_fecminor@$fecVmin@g" -e "s@insert_authPath@$authPath@" -e "s@insert_pedestals_tag@$pedestalsTag@" -e "s@insert_noise_tag@$noiseTag@" -e "s@insert_cabling_tag@$cabTag@"  -e "s@insert_connect_string@$connectString@" > $log/siStripO2O_$runNb.cfg
	   if cmsRun $log/siStripO2O_$runNb.cfg > $log/siStripO2O_$runNb.log ; then
	       echo $runString >> $storeFile
	   else
	       echo ERROR in O2O performing. EXIT!
	       echo check log file `pwd`/$log/siStripO2O_$runNb.log
	       doExit="true"
	   fi
      fi
  fi

  [[ "$doExit" != "false" ]] && break
  
done
