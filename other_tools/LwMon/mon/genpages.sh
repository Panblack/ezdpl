#!/bin/sh

gen (){

timestart=$(date +"%s")
wholeinfo=""
hostname=""
cpucount=0
ipaddr=""
date=""
baseinfo=""
w=""
meminfo=""
diskinfo=""
processinfo=""
webpage=""
warnpage=""
loadinfo=""
memtotal=0
memused=0
diskuse=0

wholeinfo=$( ssh root@$1 "ip addr show 2>/dev/null |grep -v 127.0.0.1|grep -v inet6|grep inet;echo ~~~~;hostname;echo ~~~~;cat /proc/cpuinfo |grep processor|wc -l;echo ~~~~;date --rfc-3339=date;echo ~~~~;w;echo ~~~~;free -tmo;echo ~~~~;df -Ph;echo ~~~~;pidstat|grep -v Linux|sort -k7 -r|head")

wholeinfo=${wholeinfo//</&lt;}
wholeinfo=${wholeinfo//>/&gt;}

ipaddr=${wholeinfo%%~~~~*};wholeinfo=${wholeinfo#*~~~~}
ipaddr=$(echo -e "$ipaddr"|awk '{print $2}'|sed -r -e 's/\/.*?//g')
hostname=$(echo ${wholeinfo%%~~~~*}|sed 's/\n//g') ; wholeinfo=${wholeinfo#*~~~~}
cpucount=$(echo ${wholeinfo%%~~~~*}|sed 's/\n//g') ; wholeinfo=${wholeinfo#*~~~~}
date=$(    echo ${wholeinfo%%~~~~*}|sed 's/\n//g') ; wholeinfo=${wholeinfo#*~~~~}

baseinfo="${hostname} ${cpucount}CPU(s) ${date}"
w=${wholeinfo%%~~~~*};wholeinfo=${wholeinfo#*~~~~}
meminfo=${wholeinfo%%~~~~*};wholeinfo=${wholeinfo#*~~~~}
diskinfo=${wholeinfo%%~~~~*};wholeinfo=${wholeinfo#*~~~~}
processinfo=${wholeinfo%%~~~~*};wholeinfo=${wholeinfo#*~~~~}






#Generating webpages
webpage=$(cat ${appdir}/template-page.html)
webpage=${webpage/\{SERVER\}/$1}
#webpage=${webpage/\{BASEINFO\}/$(echo -e "$hostname\n$cpucount CPU(s)\n$date $w\n")}
webpage=${webpage/\{BASEINFO\}/$(echo $baseinfo)}
webpage=${webpage/\{W\}/$(echo -e "$w")}
webpage=${webpage/\{MEMINFO\}/$(echo -e "$meminfo")}
webpage=${webpage/\{DISKINFO\}/$(echo -e "$diskinfo")}
webpage=${webpage/\{PROCESSINFO\}/$(echo -e "$processinfo")}
webpage=${webpage/\{IPADDRESS\}/$(echo -e "$ipaddr")}
echo -e "$webpage" > ${lwmon}/$1.html

#Record duration....
timeend=$(date +"%s")
echo $(expr "$timeend" - "$timestart") >> /dev/shm/$1.time

}

#Main ===========================
appdir=$(dirname $(readlink -f "$0"))
lwmon="/dev/shm/lwmon"
for x in $(cat ${appdir}/server.list); do
      server=($(echo $x|awk -F',' '{print $1,$2}'))
      ip=${server[0]}
      hostname=${server[1]}
      gen $ip $hostname
done

#Show statics
line=""
stat=""
i=0
for x in $( /bin/ls /dev/shm/*.time 2>/dev/null | sort -r) ;do	#'| sort -r' not included on github
 i=$(expr $i + 1)
 line=${x##*/}
 if [ $i -lt 10 ]; then
   line="00$i $line $(cat $x)"
 elif [ $i -lt 100 ]; then
   line="0$i $line $(cat $x)"
 else
   line="$i $line $(cat $x)"
 fi
 stat="$stat\n$line"	
done
echo -e $stat > ${lwmon}/stat.txt 

#End

