#!/bin/bash
_interface=$1
_date=`date +%F`
if ps aux|grep "iptraf -i $_interface -B -L"|grep -v grep  ;then
    echo "'iptraf -i $_interface -B -L' is running..."
else
    iptraf -i $_interface -B -L /var/log/iptraf/ip_traffic-${_interface}-${_date}.log
    echo "$_interface LOG: /var/log/iptraf/ip_traffic-${_interface}-${_date}.log"
fi
