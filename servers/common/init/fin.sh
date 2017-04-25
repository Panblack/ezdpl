#!/bin/bash
source /tmp/release.include

# crontab 
if [[ ! -f /var/spool/cron/root ]]; then
    touch /var/spool/cron/root
fi
_cron="*/10 * * * * /usr/local/bin/ban_ssh.sh
#*/10 * * * * /usr/sbin/ntpdate 0.cn.pool.ntp.org 1.cn.pool.ntp.org 2.cn.pool.ntp.org 3.cn.pool.ntp.org"
sed -i /"ban_ssh"/d /var/spool/cron/root
sed -i /"ntpdate"/d /var/spool/cron/root
echo "$_cron" >> /var/spool/cron/root
chmod 600 /var/spool/cron/root

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
	# crond
	chkconfig crond on
	service crond start
	# install epel
	if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
	    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	fi
	;;
    CENTOS7)
	# firewall
	systemctl enable firewalld
	systemctl start  firewalld
	firewall-cmd --add-port 22/tcp --permanent
	firewall-cmd --add-port 2222/tcp --permanent
	firewall-cmd --reload
	# crond
	systemctl enable crond.service
	systemctl start crond.service
	# install epel
	if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
	    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	fi
	;;
    UBUNTU)
	# firewall
	sudo ufw enable
	sudo ufw default deny
	sudo uwf allow 2222/tcp 
	;;
esac

#selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# aliyun 
if  grep "mirrors.cloud.aliyuncs.com" yum.repos.d/CentOS-Base.repo ; then
    cp -p /etc/yum.conf /etc/yum.conf.bak
    echo "exclude=kernel* centos-release*" >> /etc/yum.conf
fi

# vim auto indent(Hit <F9> for proper pasting)
# q command replaced with :q
# Q command replaced with :q!
_vimrc="set nocompatible
set shiftwidth=4
filetype plugin indent on
set pastetoggle=<F9>
nnoremap q :q
nnoremap Q :q!
"
echo "$_vimrc" > /root/.vimrc

# install packages
killall -9 yum
yum clean all
yum -y install telnet dos2unix man nmap vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils lsof sysstat dstat iftop htop openssl openssl-devel openssh bash mailx lynx git net-tools yum-utils &&  echo "Packages installed..."

if [[ -f /usr/sbin/iptraf-ng ]] ; then 
    ln -sf /usr/sbin/iptraf-ng  /usr/sbin/iptraf
    ln -sf /var/log/iptraf-ng   /var/log/iptraf
fi

# Install rpms
cd /opt/packages
yum localinstall *.rpm
