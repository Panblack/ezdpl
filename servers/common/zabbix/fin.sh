#!/bin/bash
rpm -ivh `ls /opt/packages/zabbix-release-*.noarch.rpm`
killall -9 yum
yum clean all
while true; do 
    yum install zabbix-agent -y
    if [[ $? = 0 ]];then
	break
    fi
    echo
    sleep 2
done

_hostname=`hostname -s`
sed -i 's/Server=127.0.0.1/Server=10.1.1.254/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.1.1.254/g' /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$_hostname/g" /etc/zabbix/zabbix_agentd.conf

# add 10050/tcp iptables rule to local connection.
if ! iptables -nL |grep 10050|grep ACCEPT; then
    _eth=`ip a |grep "10.1.1" -B2|head -1 |awk -F: '{print $2}'`
    _num=`iptables -nL --line-number|grep REJECT|awk '{print $1}'|head -1`
    iptables -I INPUT $_num -i $_eth -p tcp -m state --state NEW -m tcp --dport 10050 -j ACCEPT
    /etc/init.d/iptables save
    iptables -nL --line-numbers |grep 10050
fi
# iptables-iport is not powerful enough for this. 

chkconfig zabbix-agent on
service zabbix-agent start

echo "`date +%F_%T` common/zabbix " >> /tmp/ezdpl.log
