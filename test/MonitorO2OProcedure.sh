#!/bin/sh


function CreateNModTable(){

    rm -f  ${webfiletmp}_nmodtable
    for subdet in TIB TID TOB TEC
      do
      echo "<h4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$subdet</h4>" >> ${webfiletmp}_nmodtable
      echo "<TABLE  BORDER=1 ALIGN=CENTER> " >> ${webfiletmp}_nmodtable
      grep '\$\$\$' log/RootDisplay_${CondDB}_${vTag}.txt | 
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
' subdet=$subdet >> ${webfiletmp}_nmodtable
      echo "</TABLE> " >> ${webfiletmp}_nmodtable
    done
}


function CreateHistoTable(){
    identifier=$1
    thewidth=600
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
	htmlfile=`echo $file | sed -e "s@/data1@$webadd@"`	
	echo '<td valign="middle" align="center">'
	run=`echo $file| awk -F"Run_" '{print $2}' | awk -F"_" '{print $1}'`
	echo "<br><h4>Run $run</h4><br>"
	echo '<a href="'$htmlfile'"><img src="'${htmlfile}'"  style="border: 0px solid ; width: '$thewidth'px; "></a><br>'
	echo '</td>'

	if [ $i -lt $Ncol ];
	    then 
	    
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
    thewidth=600
    Ncol=2
    file=$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}
    htmlfile=`echo $file | sed -e "s@/data1@$webadd@"`	
    
    echo '<table cellpadding="2" cellspacing="2" border="0" width="100%" align="center">'
    echo '  <tbody>'
    echo '   <tr>'
            
    echo '<td valign="middle" align="center">'
    echo '<a href="'${htmlfile}.eps'"><img src="'${htmlfile}.png'"  style="border: 0px solid ; width: '$thewidth'px; "></a><br>'
    echo '</td>'
    echo '  </tbody>'
    echo '</table>'
}


function CreateHtml(){
    export webadd="http://cmstac11.cern.ch:8080"
    export htmlpath=`echo $webpath | sed -e "s@/data1@$webadd@"`

    webfile=/data1/MonitorO2O/$1/MonitorO2O_${vTag}.html
    webfiletmp=/tmp/$USER/SummaryO2O

    tableSeparator="<TD align=center>"
    tableHSeparator="<TH align=center>"
    fontColor="<font color=\"hex\">"
    greenColor="#00FF00"
    redColor="#FF0000"
    blackColor="#000000"

    rm -f ${webfiletmp}*
 
 
    #Header
    echo "<html><head><title>Summary Page $vTag</title></head>" > ${webfiletmp}

    echo "<h3>Summary Page for tag $vTag</h3>&nbsp;&nbsp;&nbsp; Check the expected/done o2o between online/offline DB: <a href=$htmlpath/OnlineToOfflineRuns_${CondDB}_${vTag}.txt>here </a><br><br>" >> ${webfiletmp}


    echo "<h4>&nbsp;&nbsp;&nbsp;Mean Noise of detected modules</h4>" >> ${webfiletmp}
    CreateTrendTable Noise >> $webfiletmp

    #echo CreateNMod
    CreateNModTable
    echo "<h4>&nbsp;&nbsp;&nbsp;Number of detected module</h4>" >> ${webfiletmp}
    cat ${webfiletmp}_nmodtable >> $webfiletmp

    echo "<h4>&nbsp;&nbsp;&nbsp;Noise of detected modules</h4>" >> ${webfiletmp}
    CreateHistoTable NoiseHisto >> $webfiletmp

    echo "<h4>&nbsp;&nbsp;&nbsp;Peds of detected module</h4>" >> ${webfiletmp}
#    CreateHistoTable Ped >> $webfiletmp


    cp $webfiletmp $webfile

#    rm -f ${webfiletmp}*
}


function getListIOV(){
    tag=${1}_p
    if [ "$2" == "devdb10" ]; then
	cmscond_list_iov -c oracle://devdb10/CMS_COND_STRIP -u CMS_COND_STRIP -p w3807dev -f "relationalcatalog_oracle://devdb10/CMS_COND_GENERAL" -t $tag | grep DB | awk '{print $1}' 
    else
	cmscond_list_iov -c oracle://orcon/CMS_COND_STRIP -u CMS_COND_STRIP_R -p R2106xon -f "relationalcatalog_oracle://orcon/CMS_COND_GENERAL" -t $tag | grep DB | awk '{print $1}' 
    fi
}


function GetPhysicsRuns(){
    
    [ -e log/O2ORuns.txt ] && rm -f log/O2ORuns.txt


    thelastUpdateDate=0
    [ -e log/AllRuns.txt ] && thelastUpdateDate=`ls -l --time-style=+%s log/AllRuns.txt |  awk '{print $6}'`
    nowDate=`date +%s`

    let delta=$nowDate-$thelastUpdateDate
    
    if [ $delta -gt 3600 ]; then
	
	echo -e "\n\t\t\t... really querying the RunSummaryTIF"
	
	wget -q -r "http://cmsdaq.cern.ch/cmsmon/cmsdb/servlet/RunSummaryTIF?RUN_BEGIN=1&RUN_END=1000000000&TEXT=1&DB=omds" -O log/AllRuns_tmp.txt  
    #Verify query integrity
	if [ `grep -c "STOPTIME" log/AllRuns_tmp.txt` != 1 ]; then
	    echo -e "ERROR: RunSummaryTIF provided a strange output"
	    cat log/AllRuns_tmp.txt
	    echo -e "\nusing old file"
	else
	    cp log/AllRuns_tmp.txt log/AllRuns.txt
	fi	
    fi

    #// Get List of PHYSIC RUNS

    cat log/AllRuns.txt | sort -n -k 1 | awk -F"\t" '{if (NR>1 && ( $3 == "LATENCY" || $3 == "PHYSIC" || $3 == "PHYSIC_ZERO_SUPPRESSION" ) ) print $1" "$2" "$12" "$14 }' | sort -n -k 1 >> log/O2ORuns.txt

}

function RunCMSSWApplication(){
    [ ! -e log/AlreadyProcessed_${CondDB}_${vTag}.txt ] && rm log/RootDisplay_${CondDB}_${vTag}.txt

    touch log/AlreadyProcessed_${CondDB}_${vTag}.txt
    for Run in `grep -v Offline log/ListOfflineO2ORuns_${CondDB}_${vTag}.txt | awk '{print $1}'`
      do
      
      [ `grep -c $Run log/AlreadyProcessed_${CondDB}_${vTag}.txt` -ne 0 ] && continue
      echo $Run >> log/AlreadyProcessed_${CondDB}_${vTag}.txt
      
      echo -e "\t\t|\n\t\t-> Run $Run"
      
      ./SiStripMonitorPedNoise.sh -run=$Run -tagPN=$tagPN -CondDb=$CondDB -tagIOV=${vTag}
      
      if [ -e root/MonitorPedNoise_${CondDB}_${vTag}.root ]; then
	  echo root.exe -q -b -l "RunAnalyzePedNoise.C(\"root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"$Run\")" 
	  root.exe -q -b -l "RunAnalyzePedNoise.C(\"root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"$Run\")" >> log/RootDisplay_${CondDB}_${vTag}.txt
	  cp IMG/Run_${Run}_*.png $webpath/IMG
      fi
    done
    echo root.exe -q -b -l "RunAnalyzePedNoise.C(\"root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"-1\",\"$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}\")" 
    root.exe -q -b -l "RunAnalyzePedNoise.C(\"root/MonitorPedNoise_${CondDB}_${vTag}.root\",\"-1\",\"$webpath/IMG/MonitorPedNoise_${CondDB}_${vTag}\")"
}

############
##  MAIN  ##
############

scriptDir=`dirname $0`
cd $scriptDir

export CondDB=""
[ "$1" != "" ] && CondDB=$1

ver="v1"
[ "$2" != "" ] && ver=$2
  
webpathBase=/data1/MonitorO2O

eval `scramv1 runtime -sh`

echo "... querying the RunSummaryTiF (really one x hour)"
GetPhysicsRuns

oldFedVer=0
oldtagPN=""
for tag in TIBTOB TIB TOB TEC TIF
  do

  echo "... looking at tag $tag"
  
  export vTag=${tag}_${ver}
  tagPN=SiStripPedNoise_${vTag}

  rm -f log/ListOnlineO2ORuns_${CondDB}_${vTag}.txt
  rm -f log/ListOfflineO2ORuns_${CondDB}_${vTag}.txt

  export webpath=${webpathBase}/${CondDB}/$vTag
  [ ! -e $webpath ] && mkdir -p $webpath && mkdir -p $webpath/IMG

  ConfigDbPartition=$tag
  [ "$tag" == "TIF" ] && ConfigDbPartition=SliceTest # note when SliceComm will be inserted, remove test from SliceTest

  oldFedV=""
  echo -e "\t\t|\n\t\t-> from OnlineDB"
  echo "OnlineDB Runs" >> log/ListOnlineO2ORuns_${CondDB}_${vTag}.txt
  for key in `grep "^[0-9]* $ConfigDbPartition" log/O2ORuns.txt | awk '{print $1 "*" $3 "*" $2}'`
    do
    Run=`echo ${key} | awk -F"*" '{print $1}'`
    FedV=`echo ${key} | awk -F"*" '{print $2}'`
    Partition=`echo ${key} | awk -F"*" '{print $3}'`

    if [ "$FedV" != "$oldFedV" ];
	then
	echo -e "$Run \t $FedV \t $Partition" >> log/ListOnlineO2ORuns_${CondDB}_${vTag}.txt
	oldFedV=$FedV
    fi
  done

  echo -e "\t\t|\n\t\t-> from OfflineDB"
  echo "OfflineDB Runs" >> log/ListOfflineO2ORuns_${CondDB}_${vTag}.txt
  for Run in `getListIOV $tagPN $CondDB`
    do
    key=`grep "^$Run " log/O2ORuns.txt | awk '{print $3 "*" $2}'`
    FedV=`echo ${key} | awk -F"*" '{print $1}'`
    Partition=`echo ${key} | awk -F"*" '{print $2}'`

    echo -e "$Run \t $FedV \t $Partition" >> log/ListOfflineO2ORuns_${CondDB}_${vTag}.txt
  done
  
  rm -f log/OnlineToOfflineRuns_${CondDB}_${vTag}.txt
  sdiff log/ListOnlineO2ORuns_${CondDB}_${vTag}.txt log/ListOfflineO2ORuns_${CondDB}_${vTag}.txt > log/OnlineToOfflineRuns_${CondDB}_${vTag}.txt

  cp log/OnlineToOfflineRuns_${CondDB}_${vTag}.txt $webpath

  echo "... checking validity for each uploaded IOV"
  RunCMSSWApplication

  echo -e "\t\t|\n\t\t-> Creating WebPage"
  CreateHtml $CondDB
done
