#!/bin/bash

_thedate=`date +%Y%m%d`
_thetime=`date +%Y-%m-%d.%H:%M:%S`
_thepath=/opt/hpstat
_thefile=hpstat_slb01_$_thedate

mkdir -p $_thepath
echo "$_thetime" >> /$_thepath/${_thefile}.log
echo "show stat"|nc -U /var/lib/haproxy/stats >> /$_thepath/${_thefile}.log
/bin/cp -pn /var/log/haproxy.log-* /opt/haproxy.log/
