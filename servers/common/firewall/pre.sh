#!/bin/bash

source /usr/local/bin/release.include
echo $_RELEASE

_ports="22 2222"
# firewalld 
case $_RELEASE in
    CENTOS6)
        # firewall
        chkconfig iptables on
        service iptables start
        iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
	for x in $_ports; do
            iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport $x -j ACCEPT
	done
        iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
        /etc/init.d/iptables save
        ;;
    CENTOS7)
        # firewall
        systemctl enable firewalld
        systemctl start  firewalld
	for x in $_ports; do 
	    firewall-cmd --add-port $x/tcp --permanent
        done
        firewall-cmd --reload
        ;;
    UBUNTU)
        # firewall
        sudo ufw enable
        sudo ufw default deny
	for x in $_ports; do
            sudo ufw allow $x/tcp
	done
        ;;
esac
echo "`date +%F_%T` common/firewall " >> /tmp/ezdpl.log
