#!/bin/bash
if [[ -z $1 ]]; then
    _limit=32
else
    _limit=$1
fi
set -e
set -u

_haproxy_log_file="/var/log/haproxy.log"
_404_log_file="/opt/haproxy.log/haproxy_404.log"
_detail_404_log_file="/opt/haproxy.log/haproxy_detail_404.log"
if [[ ! -f $_404_log_file ]]; then
    touch $_404_log_file
fi
_ip_total=`grep " 404 " $_haproxy_log_file |grep -v " 404 -" |awk '{print $6}'|awk -F: '{print $1}'|sort`
_ip_single=`echo "$_ip_total" |uniq -c|sort -gr`
IFS="
"
for x in $_ip_single; do
    _count=`echo "$x"|awk '{print $1}'`
    _ip=`echo "$x"   |awk '{print $2}'`
    #Pick thost repeating more than $_limit
    if [[ $_count -gt $_limit ]] ; then
	echo "`date +%F_%T` $x" >> $_detail_404_log_file
	if ! grep $_ip $_404_log_file >/dev/null ; then
	    _ip_position=`/usr/local/bin/ipq $_ip`
 	    echo -e "${_ip}\t${_count}\t${_ip_position}" >> $_404_log_file 
	    sleep 1
	fi
    else
	break
    fi
done

set +e
set +u
