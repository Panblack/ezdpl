#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

case $_RELEASE in
    CENTOS6)
	# firewall
    	iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
	iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
    	iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
	/etc/init.d/iptables save
	;;
    CENTOS7)
	# firewall
	firewall-cmd --add-port 3306/tcp --permanent
	firewall-cmd --reload
	;;
    UBUNTU)
	# firewall
	sudo uwf allow 3306/tcp 
	;;
esac

echo "`date +%F_%T` mysql/firewall " >> /tmp/ezdpl.log

