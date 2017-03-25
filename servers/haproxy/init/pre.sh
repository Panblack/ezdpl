#!/bin/bash

mkdir -p /opt/haproxy.log
mkdir -p /opt/hpstat

killall -9 yum
yum clean all
yum -y install haproxy sendmail mailx  
chkconfig haproxy on
chkconfig sendmail on

iptables-iport a "80 8080 443" t
