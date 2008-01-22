#!/bin/sh

function CreateNModTable(){
    inputFile=$1
    rm -f  ${webfiletmp}_nmodtable
    for subdet in TIB TID TOB TEC
      do
      echo "<h4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$subdet</h4>" 
      echo "<TABLE  BORDER=1 ALIGN=CENTER> " 
      grep '\$\$\$' $inputFile | 
      awk 'BEGIN{layers="";oldlayers="";Entries=""; Total=0; flag=0}
{for(i=2;i<NF;i++) 
{
if(index($i,subdet)){ 
layers=sprintf("%s <TD align=center> %s",layers,$i); 
Entries=sprintf("%s <TD align=center> %d",Entries,$(i+1)); 
Total+=$(i+1);
}
}
if(index($1,"$$$")){if(layers!=oldlayers && layers!="") {print "<TD> Run " layers "<TD align=center> Total<TR>"; flag=1;oldlayers=layers;} if(Entries!="") print "<TD> " $2 "\t" Entries "<TD align=center> " Total " <TR>"; layers="";Entries="";Total=0 }
} 
' subdet=$subdet | sed -e "s@${subdet}_@@g"

      echo "</TABLE> " 
    done
}


function CreateHistoTable(){
    identifier=$1
    thewidth=400
    Ncol=2
    for subdet in TIB TID TOB TEC
      do
      echo "<h4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$subdet</h4>" 
      echo '<table cellpadding="2" cellspacing="2" border="0" width="100%" align="center">'
      echo '  <tbody>'
      echo '   <tr>'
            
      i=1
      for file in `ls $webpath/IMG/Run*_*${identifier}*${subdet}*png 2>/dev/null`
	do
	htmlfile=`echo $file | sed -e "s@$webpathBase@$webadd@"`	
	echo '<td valign="middle" align="center">'
	run=`echo $file| awk -F"Run_" '{print $2}' | awk -F"_" '{print $1}'`
	echo "<br><h4>Run $run</h4><br>"
	echo '<a href="'$htmlfile'"><img src="'${htmlfile}'"  style="border: 0px solid ; width: '$thewidth'px; "></a><br>'
	echo '</td>'

	if [ $i -lt $Ncol ];
	    then 
	    echo '<td>'
	    let i+=1
	else 
	    echo '    </tr>'
	    echo '    <tr>'
	    i=1
	fi
      done
      echo '  </tbody>'
      echo '</table>'
    done
}


function CreateTrendTable(){
    identifier=$1
    thewidth=500
    Ncol=2
    Basefile=$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}

    echo '<table cellpadding="2" cellspacing="2" border="0" width="100%" align="center">'
    echo '  <tbody>'

    for det in TIB TID TOB TEC
      do
      file=${Basefile}_${det}
      #[ ! -e ${file}.eps ] && continue
      htmlfile=`echo $file | sed -e "s@$webpathBase@$webadd@"`	
      echo '<td valign="middle" align="center"><h4>'$det'</h4>'
      echo '<a href="'${htmlfile}.eps'"><img src="'${htmlfile}.png'"  style="border: 0px solid ; width: '$thewidth'px; "></a>'
      if [ "$det" == "TID" ] || [ "$det" ==  "TEC" ]  ;
	  then
	  echo '<tr>'
      fi
    done
    echo '  </tbody>'
    echo '</table>'
}


function CreateHtml(){

    tableSeparator="<TD align=center>"
    tableHSeparator="<TH align=center>"
    fontColor="<font color=\"hex\">"
    greenColor="#00FF00"
    redColor="#FF0000"
    blackColor="#000000"

    rm -f ${webfiletmp}*
 
 
    #Header
    echo "<html><head><title>Summary Page $vTag</title></head>" > ${webfiletmp}

    echo "<h2>Summary Page for tag $vTag</h2>&nbsp;&nbsp;&nbsp; list of uploaded IOVs: <a href=$htmlpath/O2ORuns.txt>here </a><br><br>" >> ${webfiletmp}
    echo "<HR>" >>  $webfiletmp


    echo "<h3>&nbsp;&nbsp;&nbsp;Mean Noise of detected modules</h3>" >> ${webfiletmp}
    CreateTrendTable Noise >> $webfiletmp
    echo "<HR>" >>  $webfiletmp

    #echo CreateNMod
    echo "<h3>&nbsp;&nbsp;&nbsp;Number of detected modules</h3>" >> ${webfiletmp}
    CreateNModTable $tmpbase/log/RootDisplay_${CondDB}_${vTag}.txt >> $webfiletmp
    echo "<HR>" >>  $webfiletmp

    echo "<h3>&nbsp;&nbsp;&nbsp;Number of detected strips</h3>" >> ${webfiletmp}
    CreateNModTable $tmpbase/log/RootDisplay_${CondDB}_${vTag}_Trend.txt >> $webfiletmp
    echo "<HR>" >>  $webfiletmp

    echo "<h3>&nbsp;&nbsp;&nbsp;Link to the root file with histograms <a href=$htmlpath/root/MonitorPedNoise_${CondDB}_${vTag}.root>here </a> </h3>" >> ${webfiletmp}
    echo "<HR>" >>  $webfiletmp

    rm -f  $webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}.html
    CreateHistoTable NoiseHisto > $webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}.html
    echo "<h3>&nbsp;&nbsp;&nbsp;Noise of detected modules  <a href=$htmlpath/IMG/MonitorPedNoise_${CondDB}_${vTag}.html> here </a></h3>" >> ${webfiletmp}
    echo "<HR>" >>  $webfiletmp

#    echo "<h4>&nbsp;&nbsp;&nbsp;Noise of detected modules</h4>" >> ${webfiletmp}


#    echo "<h4>&nbsp;&nbsp;&nbsp;Peds of detected module</h4>" >> ${webfiletmp}
#    CreateHistoTable Ped >> $webfiletmp


    cp $webfiletmp $webfile

#    rm -f ${webfiletmp}*
}

function perRunAnalysis(){

grep TIF2 log/O2ORuns.txt | while read line
  do

  run=`echo $line | cut -f 1 -d " "`
  partition=`echo $line | cut -f 2 -d " " `
  Mfedv=`echo $line | cut -f 4 -d " " | cut -f 1 -d "."`
  mfedv=`echo $line | cut -f 4 -d " " | cut -f 2 -d "."`

  echo -e "\n\n\n"
  echo .... analyzing run $run $partition $Mfedv $mfedv

  cat template_sistripo2o.cfg | sed -e "s@insert_Run@$run@g" -e "s@insert_ConfigDbPartition@$partition@g" -e "s@insert_fedmajor@$Mfedv@g" -e "s@insert_fedminor@$mfedv@g" > log/SiStripO2O_$run.cfg

  echo "cmsRun  log/SiStripO2O_$run.cfg > log/Log_$run.log"

  cd ../MonitorO2O
  [ ! -e $tmpbase/SiStripMonitorPedNoise_${CondDB}_${vTag}_${run}.out ] && ./SiStripMonitorPedNoise.sh -run=$run -tagP=$tagp -tagN=$tagn -tagCab=$tagc -CondDb=${CondDB} -tagIOV=${vTag}
  
  if [ -e $tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root ]; then
      echo -e "\nroot.exe -q -b -l \"RunAnalyzePedNoise.C(\"$tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"$run\",\"$webpath/IMG\")\""
      root.exe -q -b -l "RunAnalyzePedNoise.C(\"$tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"$run\",\"$webpath/IMG\")" >> $tmpbase/log/RootDisplay_${CondDB}_${vTag}.txt
      echo 
  fi
  cd -
#break
done
}


############
##  MAIN  ##
############

scriptDir=`dirname $0`
cd $scriptDir

export CondDB="cms_orcoff_int2r"
[ "$1" != "" ] && CondDB=$1

ver="pass4_v1"
[ "$2" != "" ] && ver=$2
  
#webpathBase=/data1
webpathBase=/tmp/giordano/web
[ "$3" != "" ] && webpathBase=$3

echo CondDB $CondDB
echo tag $ver
echo webpathBase $webpathBase

eval `scramv1 runtime -sh`

#FIXME
tagn=SiStripNoises_pass4_test_v1_n
tagp=SiStripPedestals_pass4_test_v1_p
tagc=SiStripCabling_pass4_test_v1


export vTag=${ver}
export webpath=${webpathBase}/MonitorO2O/${CondDB}/$vTag
[ ! -e $webpath ] && mkdir -p $webpath && mkdir -p $webpath/IMG

#export webadd="http://cmstac11.cern.ch:8080"
export webadd="http://webcms.ba.infn.it/~giordano"
export htmlpath=`echo $webpath | sed -e "s@${webpathBase}@$webadd@"`

export webfile=$webpath/../MonitorO2O_${vTag}.html
webfiletmp=/tmp/$USER/webfiletmp


rm dbfile.db
#cmscond_bootstrap_detector.pl --offline_connect sqlite_file:dbfile.db --auth /afs/cern.ch/cms/DB/conddb/authentication.xml STRIP

export tmpbase=/tmp/giordano/MonitorO2O
mkdir $tmpbase
mkdir $tmpbase/root
mkdir $tmpbase/IMG
mkdir $tmpbase/log

mkdir log
echo 'wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt'

#wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns.txt

echo "extracting o2o runs"
echo 
cat log/AllRuns.txt | sort -n -k 1 | awk -F"\t" 'BEGIN{fedv=0} {if (NR>1 && ( $3 == "LATENCY" || $3 == "PHYSIC" || $3 == "PHYSIC_ZERO_SUPPRESSION" ) && fedv != $13) {fedv=$13;  a=sprintf("%d \t %30s \t  %30s \t %6.2f \t %s",$1,$2,$3,$13,$15); print a} }' | sort -n -k 1 >! log/O2ORuns.txt


rm $tmpbase/log/RootDisplay_${CondDB}_${vTag}.txt

perRunAnalysis

echo
echo root.exe -q -b -l "RunAnalyzePedNoise.C(\"$tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"-1\",\"$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}\")"
echo 
cd ../MonitorO2O
root.exe -q -b -l "RunAnalyzePedNoise.C(\"$tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"-1\",\"$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}\")"  > $tmpbase/log/RootDisplay_${CondDB}_${vTag}_Trend.txt

cd -

echo "... checking validity for each uploaded IOV"

echo -e "\t\t|\n\t\t-> Creating WebPage"
CreateHtml $CondDB

mkdir $webpath/root
cp $tmpbase/root/MonitorPedNoise_${CondDB}_${vTag}.root $webpath/root
cp log/O2ORuns.txt $webpath
echo webfile $webfile




