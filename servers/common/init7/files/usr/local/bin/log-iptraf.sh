#!/bin/bash
_oper=$1
_interface=$2
_date=`date +%F_%H%M`
_log_path="/var/log/iptraf"

case $_oper in
    ps)
	ps aux|grep "iptraf -i" | grep -v grep | grep -v $0
	;;
    stat)
#    	_du=`/usr/bin/du -hx --max-depth=1 ${_log_path}|tr -d "${_log_path}"`
	echo -e "Size\tVRRP\tICMP\tTCP\tUDP\tLogFile"
    	for x in ${_log_path}/ip_traffic-*.log ; do
	    _du=`du -h $x|awk '{print $1}'`
	    _vrrp=`grep VRRP $x|wc -l`
	    _icmp=`grep ICMP $x|wc -l`
	    _tcp=` grep TCP  $x|wc -l`
	    _udp=` grep UDP  $x|wc -l`
            echo -e "${_du}\t${_vrrp}\t${_icmp}\t${_tcp}\t${_udp}\t${x}"
    	done
	;;
    stop)
	killall iptraf
	;; 
    start)
	if [[ -z $_interface ]]; then
	    echo "Network interface missing."
	    exit 1
	fi
	if ps aux|grep "iptraf -i $_interface -B -L"|grep -v grep  ;then
    	    echo "'iptraf -i $_interface -B -L' is running..."
	else
	    cd /var/lock/iptraf && /bin/rm iptraf-ipmon.tag.${_interface} -f 2>/dev/null
    	    iptraf -i $_interface -B -L ${_log_path}/ip_traffic-${_interface}-${_date}.log 2>&1
    	    echo "$_interface LOG: ${_log_path}/ip_traffic-${_interface}-${_date}.log"
	fi
	;;
    *)
	echo  "
Usage: 
log-iptraf.sh start <iface>	Start Logging
log-iptraf.sh stat		Log Stats
log-iptraf.sh ps		Show Logging Processes
log-iptraf.sh stop		Stop Logging."
	;;
esac
