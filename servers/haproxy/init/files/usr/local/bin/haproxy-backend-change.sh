#!/bin/bash
_time=`date +%H:`
_host=`hostname -s`

#Get the latest DOWN/UP event
_down=`grep "is DOWN"  /var/log/haproxy.log |tail -1`
_up=`  grep "is UP"    /var/log/haproxy.log |tail -1`

#Replace tow spaces with one.
_down=${_down//  / }
_up=${_up//  / }

#Get the last log record.
_downchk=`cat /var/log/haproxy-backend-down.log 2>/dev/null`
_upchk=`cat /var/log/haproxy-backend-up.log 2>/dev/null`

if [[ -n $_down ]];then
  # if the first 16 characters are not the same.
  if [[ ${_down:0:16} != ${_downchk:0:16} ]];then
    echo $_down | mail -s "$_host Backend DOWN" recv@example.com
  fi
  #Update the log record.
  echo "$_down" > /opt/haproxy.log/haproxy-backend-down.log
fi
if [[ -n $_up ]];then
  # if the first 16 characters are not the same.
  if [[ ${_up:0:16} != ${_upchk:0:16} ]];then
    echo -e $_up | mail -s "$_host Backend UP" recv@example.com
  fi
  #Update the log record.
  echo "$_up" > /opt/haproxy.log/haproxy-backend-up.log
fi
