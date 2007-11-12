#!/bin/sh

scriptDir=`dirname $0`
cd $scriptDir

[ -e lockFile ] && exit
touch lockFile

./MonitorO2OProcedure.sh orcon v1
./MonitorO2OProcedure.sh orcon test1

rm lockFile

