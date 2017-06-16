#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

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

#selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# aliyun (exclude kernel centos-release when `yum update`) 
if egrep "(mirrors.aliyuncs.com|mirrors.aliyun.com)" /etc/yum.repos.d/CentOS-Base.repo &>/dev/null ; then
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
for x in `ps aux|egrep -i 'yum.*install' |grep -v grep|awk '{print $2}'`; do
    kill -9 $x
done

yum clean all
yum install -y epel-release
yum update -y
yum -y install yum-utils deltarpm telnet dos2unix man nmap vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils lsof sysstat dstat iftop htop openssl openssl-devel openssh bash mailx lynx git net-tools psmisc rkhunter tcptraceroute python-pip && echo "Packages installed..."

# Update the entire file properties database 
rkhunter --propupd
echo

# python pip & tools
echo "pip install memcached-cli, httpie"
pip install --upgrade pip
pip install memcached-cli httpie
echo

if [[ -f /usr/sbin/iptraf-ng ]] ; then 
    ln -sf /usr/sbin/iptraf-ng  /usr/sbin/iptraf
    ln -sf /var/log/iptraf-ng   /var/log/iptraf
fi

# Install rpms
cd /opt/packages
yum localinstall *.rpm

echo "`date +%F_%T` common/init " >> /tmp/ezdpl.log
