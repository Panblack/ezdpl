#!/bin/bash

source /usr/local/bin/release.include
echo $_RELEASE

# firewalld 
case $_RELEASE in
    CENTOS6)
        # firewall
        # Consider change sshd port to 2222 later.
        chkconfig iptables on
        service iptables start
        iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8009 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8081 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8082 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8083 -j ACCEPT
        iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
        /etc/init.d/iptables save
	# nginx repo
	sed -i 's/X/6/g' /etc/yum.repos.d/nginx.repo
        ;;
    CENTOS7)
        # firewall
        systemctl enable firewalld
        systemctl start  firewalld
	firewall-cmd --add-port 80/tcp --permanent
	firewall-cmd --add-port 443/tcp --permanent
	firewall-cmd --add-port 8009/tcp --permanent
	firewall-cmd --add-port 8080/tcp --permanent
	firewall-cmd --add-port 8081/tcp --permanent
	firewall-cmd --add-port 8082/tcp --permanent
	firewall-cmd --add-port 8083/tcp --permanent
        firewall-cmd --reload
	# nginx repo
	sed -i 's/X/7/g' /etc/yum.repos.d/nginx.repo
        ;;
    UBUNTU)
        # firewall
        sudo ufw enable
        sudo ufw default deny
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw allow 8009/tcp
        sudo ufw allow 8080/tcp
        sudo ufw allow 8081/tcp
        sudo ufw allow 8082/tcp
        sudo ufw allow 8083/tcp
        ;;
