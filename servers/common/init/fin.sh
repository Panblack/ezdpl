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
yum -y install yum-utils deltarpm telnet dos2unix man nmap vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils lsof sysstat dstat iftop geoip htop openssl openssl-devel openssh bash mailx lynx git net-tools psmisc rkhunter tcptraceroute python-pip && echo "Packages installed..."

# iftoprc
_iftoprc="
dns-resolution: yes
port-resolution: no
show-bars: yes
promiscuous: yes
port-display: on
use-bytes: yes
sort: source
line-display: one-line-both
show-totals: yes 
log-scale: yes
"
echo "$_iftoprc" > ~/.iftoprc

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
