#!/bin/bash
#search /var/log/haproxy.log for http 404 requests.
#extract the source ip address.
#find the location for the ip.
#store in a logfile.

if [[ -z $1 ]]; then
    _limit=32
else
    _limit=$1
fi
set -e
set -u

_haproxy_log_file="/var/log/haproxy.log"
_404_log_file="/root/haproxy_404.log"

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
        if ! grep $_ip $_404_log_file >/dev/null ; then
            _ip_location=`curl -s http://wap.ip138.com/ip_search138.asp?ip=$_ip|grep "<b>$_ip"|sed "s/<b>//g;s/<\/b>//g;s/<br\/>//g;s/$_ip//g"` 
            echo -e "${_ip}\t${_count}\t${_ip_location}" >> $_404_log_file 
            sleep 1
        fi
    else
        break
    fi
done

set +e
set +u
