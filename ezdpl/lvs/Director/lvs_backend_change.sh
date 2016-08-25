#!/bin/bash
# Send alert mail when Real Server online/offline.
# Works with Centos6. 
# Service sendmail must be configured in advance.

# First check if VIP is present.
# Asuming there are two LVS Directors, both configured with keepalived.
# The standby server will not send alert mails.
if ! /sbin/ip addr show eth0|grep 'inet'|grep '/32' &>/dev/null ; then
    exit 0
fi

_time=`date +%H:`
_hostname=`hostname -s`

#Get the latest DOWN/UP event
_down=`grep -B1 "Removing service"  /var/log/messages |tail -2`
_up=`grep -B1 "Adding service" /var/log/messages |tail -2`

#Replace double spaces with one.
_down=${_down//  / }
_up=${_up//  / }

#Get the log record.
_downchk=`cat /var/log/lvs-backend-down.log 2>/dev/null`
_upchk=`cat /var/log/lvs-backend-up.log 2>/dev/null`

if [[ -n $_down ]];then
  # if the first 16 characters are not the same.
  if [[ ${_down:0:16} != ${_downchk:0:16} ]];then
    echo $_down | mail -s "$_hostname Backend DOWN." YourName@YourMailServer.com
  fi
  #Update the log record.
  echo $_down > /var/log/lvs-backend-down.log
fi
if [[ -n $_up ]];then
  # if the first 16 characters are not the same.
  if [[ ${_up:0:16} != ${_upchk:0:16} ]];then
    echo -e $_up | mail -s "$_hostname Backend UP." YourName@YourMailServer.com
  fi
  #Update the log record.
  echo $_up > /var/log/lvs-backend-up.log
fi

