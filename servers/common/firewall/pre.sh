#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

case $_RELEASE in
    CENTOS6)
	# timezone
	/bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	# firewall
	# Consider change sshd port to 2222 later.
	chkconfig iptables on
	service iptables start
    	iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
	iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
    	iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
	/etc/init.d/iptables save
	# install epel
	if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
	    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	fi
	;;
    CENTOS7)
	# timezone
	timedatectl set-timezone Asia/Shanghai
	# firewall
	systemctl enable firewalld
	systemctl start  firewalld
	firewall-cmd --add-port 22/tcp --permanent
	firewall-cmd --add-port 2222/tcp --permanent
	firewall-cmd --reload
	;;
    UBUNTU)
	# firewall
	sudo ufw enable
	sudo ufw default deny
	sudo uwf allow 2222/tcp 
	;;
esac

