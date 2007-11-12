#!/bin/sh

function usage(){
    echo -e "\n[usage] SiStripMonitorPedNoise.sh [options]"
    echo -e " -help  this message"
    echo -e " -run=<runNb>"
    echo -e " -tagPN=<tag for PedNoise> (default is ${default_tagPN} )"
    echo -e " -tagCab=<tag for cabling> (default is ${default_tagCab} )"
    echo -e " -CondDb=<sqlite>, <devdb10>, <orcon>, <orcoff> (default is sqlite)"
    echo -e " -sqliteDb=<dbfile> (needed for CondDb=sqlite - default is /tmp/$USER/dummy_<runNb>.db)"
    echo -e " -sqliteCatalog=<dbcatalog> (needed for CondDb=sqlite - default is /tmp/$USER/dummy_<runNb>.db )"
    exit
}

function getParameter(){
    what=$1
    shift
    where=$@
    if [ `echo $where | grep -c "\-$what="` = 1 ]; then
        eval $what=`echo $where | awk -F"${what}=" '{print $2}' | awk '{print $1}'`
    elif [ `echo $where | grep -c "\-$what"` = 1 ]; then
	eval $what=1
    else
	let c=$#-1
	shift $c
	eval $what=$1
    fi
}

#################
## MAIN
#################

default_tagPN=SiStripPedNoise_v1
default_tagCab=SiStripCabling_v1
default_tagIOV=v1

[ `echo $@ | grep -c "\-help"` = 1 ] && usage;

test_area=/tmp/$USER/MonitorO2O
[ ! -e ${test_area} ] && mkdir -p ${test_area}

getParameter run            $@ -1
getParameter tagPN          $@ ${default_tagPN}
getParameter tagCab         $@ ${default_tagCab}
getParameter tagIOV         $@ ${default_tagIOV}
getParameter CondDb         $@ sqlite
getParameter sqliteDb       $@ ${test_area}/dummy_${run}.db
getParameter sqliteCatalog  $@ ${test_area}/dummy_${run}.xml

[ "$run" == "-1" ] && echo -e "\nWORNING: please specify a run number" && usage

if [ "$CondDb" == "sqlite" ] && [ "$sqliteDb" != "" ] && [ "$sqliteCatalog" != "" ]; 
    then
    DBfile="sqlite_file:${sqliteDb}"
    DBcatalog="file:${sqliteCatalog}"
elif [ "$CondDb" == "devdb10" ];  then
    DBfile="oracle://devdb10/CMS_COND_STRIP"
    DBcatalog="relationalcatalog_oracle://devdb10/CMS_COND_GENERAL"
elif [ "$CondDb" == "orcon" ]; then
    DBfile="oracle://orcon/CMS_COND_STRIP"
    DBcatalog="relationalcatalog_oracle://orcon/CMS_COND_GENERAL"
elif [ "$CondDb" == "cms_orcoff_int2r" ]; then
    DBfile="oracle://cms_orcoff_int2r/CMS_COND_STRIP"
    DBcatalog="relationalcatalog_oracle://cms_orcoff_int2r/CMS_COND_GENERAL"
elif [ "$CondDb" == "orcoff" ]; then
    DBfile="oracle://cms_orcoff/CMS_COND_STRIP"
    DBcatalog="relationalcatalog_oracle://cms_orcoff/CMS_COND_GENERAL"
else
    echo -e "\nERROR: Wrong options"
    usage
fi

echo -e " -run=$run"
echo -e " -tagPN=$tagPN"
echo -e " -tagCab=$tagCab"
echo -e " -tagIOV=$tagIOV"

echo -e " -CondDb=$CondDb"
if [ "$CondDb" = "sqlite" ]; then
    echo -e " -sqliteDb=${sqliteDb}"
    echo -e " -sqliteCatalog=${sqliteCatalog}"
fi
echo " "

output_file_name=/tmp/giordano/MonitorO2O/root/MonitorPedNoise_${CondDb}_${tagIOV}.root 
cfg_file=${test_area}/SiStripMonitorPedNoise_${CondDb}_${tagIOV}_${run}.cfg
out_file=${test_area}/SiStripMonitorPedNoise_${CondDb}_${tagIOV}_${run}.out

echo ${cfg_file}

export TNS_ADMIN=/afs/cern.ch/project/oracle/admin
export CORAL_AUTH_PATH=/afs/cern.ch/cms/DB/conddb

eval `scramv1 runtime -sh`

templatefile=${CMSSW_BASE}/src/OnlineDB/SiStripO2O/test/MonitorO2O/template_SiStripMonitorPedNoise.cfg
[ ! -e $templatefile ] && templatefile=${CMSSW_RELEASE_BASE}/src/OnlineDB/SiStripO2O/test/MonitorO2O/template_SiStripMonitorPedNoise.cfg
[ ! -e $templatefile ] && echo "ERROR: expected template file doesn't exist both in your working area and in release area. Please fix it." && exit

cat $templatefile | sed -e "s#insert_runNb#${run}#g" -e "s#insert_DBfile#$DBfile#" -e "s#insert_DBcatalog#$DBcatalog#" -e "s#insert_output_filename#${output_file_name}#"  -e "s#insert_tagPN#${tagPN}#g"  -e "s#insert_tagCab#${tagCab}#g" > ${cfg_file}
echo "cmsRun ${cfg_file}"
cmsRun ${cfg_file} > ${out_file}

echo -e "\nroot file can be found in  ${test_area}\n\t ${output_file_name}" 
echo -e "\nout file can be found in ${out_file}"

