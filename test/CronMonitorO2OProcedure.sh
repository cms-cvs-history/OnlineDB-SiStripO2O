#!/bin/sh

scriptDir=`dirname $0`
cd $scriptDir

eval `scramv1 runtime -sh`
[ -e lockFile ] && exit
touch lockFile

#./MonitorO2OProcedure.sh orcon v1
#./MonitorO2OProcedure.sh orcon 09072007_DQM_v070713
#./MonitorO2OProcedure.sh orcon 29062007_DQM_v070713
#./MonitorO2OProcedure.sh orcon DQM_v070713
#./MonitorO2OProcedure.sh orcon 09072007_DQM_v070716
#./MonitorO2OProcedure.sh orcon 09072007_DQM_vlastNight
./MonitorO2OProcedure.sh orcon 140_test23
#./MonitorO2OProcedure.sh orcon 140_test3
#./MonitorO2OProcedure.sh orcon 29062007_140_test4
#./MonitorO2OProcedure.sh orcon venturi_v1
#./MonitorO2OProcedure.sh orcon test1

rm lockFile

