#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

case $_RELEASE in
    CENTOS6)
	# firewall
	# Consider change sshd port to 2222 later.
	chkconfig iptables on
	service iptables start
    	iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
	iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
    	iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
	/etc/init.d/iptables save
	;;
    CENTOS7)
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

echo "`date +%F_%T` common/firewall " >> /tmp/ezdpl.log

