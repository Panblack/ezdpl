#!/bin/bash
rpm -ivh /tmp/zabbix-release-2.4-1.el6.noarch.rpm
yum install zabbix-agent -y
sleep 1
_hostname=`hostname -s`
sed -i 's/Server=127.0.0.1/Server=10.1.1.254/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.1.1.254/g' /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$_hostname/g" /etc/zabbix/zabbix_agentd.conf

if ! iptables -nL |grep 10050|grep ACCEPT; then
    _eth=`ip a |grep 10.1.1 -B2|head -1 |awk -F: '{print $2}'`
    _num=`iptables -nL --line-number|grep REJECT|awk '{print $1}'|head -1`
    iptables -I INPUT $_num -i $_eth -p tcp -m state --state NEW -m tcp --dport 10050 -j ACCEPT
    /etc/init.d/iptables save
    iptables -nL --line-numbers |grep 10050
fi

chkconfig zabbix-agent on
service zabbix-agent start

