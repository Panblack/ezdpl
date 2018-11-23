#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE
case $_RELEASE in
    CENTOS6)
	rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/6/x86_64/zabbix-release-4.0-1.el6.noarch.rpm
	killall -9 yum
	yum clean all
	yum install -y zabbix-agent
	chkconfig zabbix-agent on
        ;;
    CENTOS7)
	rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
	killall -9 yum
	yum clean all
	yum install -y zabbix-agent
	systemctl enable zabbix-agent
        ;;
    UBUNTU)
	#18.04
	wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
	dpkg -i zabbix-release_4.0-2+bionic_all.deb
	apt update
	apt install -y zabbix-agent
        ;;
esac

_server_ip="1.2.3.4"
_hostname=`hostname -s`
sed -i 's/Server=127.0.0.1/Server='$_server_ip'/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive='$_server_ip'/g' /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$_hostname/g" /etc/zabbix/zabbix_agentd.conf

/usr/local/bin/iptables-iport a 10050

# add 10050/tcp iptables rule to local connection.
#if ! iptables -nL |grep 10050|grep ACCEPT; then
#    _eth=`ip a |grep "10.1.1" -B2|head -1 |awk -F: '{print $2}'`
#    _num=`iptables -nL --line-number|grep REJECT|awk '{print $1}'|head -1`
#    iptables -I INPUT $_num -i $_eth -p tcp -m state --state NEW -m tcp --dport 10050 -j ACCEPT
#    /etc/init.d/iptables save
#    iptables -nL --line-numbers |grep 10050
#fi

service zabbix-agent start
echo "`date +%F_%T` common/zabbix " >> /tmp/ezdpl.log
