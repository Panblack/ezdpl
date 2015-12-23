#!/bin/bash
yum -y install telnet man vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils lsof sysstat
if [ "$?" = "0" ];then
   echo "Packages installed..."
fi

chkconfig crond on
service crond start

