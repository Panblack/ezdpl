#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# crontab 
if [[ ! -f /var/spool/cron/root ]]; then
    touch /var/spool/cron/root
fi
_cron="*/10 * * * * /usr/local/bin/ban_ssh.sh
*/10 * * * * /usr/sbin/ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com ntp4.aliyun.com"
sed -i /"ban_ssh"/d /var/spool/cron/root
sed -i /"ntpdate"/d /var/spool/cron/root
echo "$_cron" >> /var/spool/cron/root
chmod 600 /var/spool/cron/root

# logrotate.conf
sed -i 's/rotate 4/rotate 104/g' /etc/logrotate.conf

# selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# stop and disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# sshd port 2222, UseDNS no
#sed -i 's/^#Port 22/Port 2222/g' /etc/ssh/sshd_config
#sed -i 's/^#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config

# history record
_LOGOUT_HISTORY="mkdir -p ~/.history ; history &>> ~/.history/.history.\`whoami\`.\`date +%F_%H%M\`.log"
sed -i '/history/d' ~/.bash_logout
sed -i '/history/d' /etc/skel/.bash_logout
echo "$_LOGOUT_HISTORY" >> ~/.bash_logout
echo "$_LOGOUT_HISTORY" >> /etc/skel/.bash_logout

# aliyun (exclude kernel centos-release when `yum update`) 
if egrep "(mirrors.aliyuncs.com|mirrors.aliyun.com|mirrors.cloud.aliyuncs.com|mirrors.cloud.aliyun.com)" /etc/yum.repos.d/CentOS-Base.repo &>/dev/null ; then
    cp -p /etc/yum.conf /etc/yum.conf.bak
    echo "exclude=kernel* centos-release*" >> /etc/yum.conf
fi

# install packages
for x in `ps aux|egrep -i 'yum' |grep -v grep|awk '{print $2}'`; do
    kill $x || kill -9 $x
done
yum clean all

case $_RELEASE in
    CENTOS6)
        # timezone
        /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        # install epel
        if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
            rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
        fi
        ;;
    CENTOS7)
        # timezone
        timedatectl set-timezone Asia/Shanghai
        # install epel
        if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
            rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        fi
        ;;
    UBUNTU)
        # timezone
        /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        ;;
esac

yum update -y
yum -y install yum-utils deltarpm telnet dos2unix man nmap vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils nethogs lsof sysstat dstat iftop geoip htop openssl openssl-devel openssh bash mailx lynx git net-tools psmisc rkhunter tcptraceroute python-pip && echo "Packages installed..."

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
echo "$_vimrc" > /etc/skel/.vimrc

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
echo "$_iftoprc" > /etc/skel/.iftoprc

# python pip & tools
echo "pip install httpie"
pip install --upgrade pip
#pip install memcached-cli httpie
echo

if [[ -f /usr/sbin/iptraf-ng ]] ; then 
    ln -sf /usr/sbin/iptraf-ng  /usr/sbin/iptraf
    ln -sf /var/log/iptraf-ng   /var/log/iptraf
fi

# Install rpms
cd /opt/packages
yum localinstall *.rpm

# Update the entire file properties database 
echo "rkhunter --propupd ..."
rkhunter --propupd
echo

service sshd restart
echo "`date +%F_%T` common/init " >> /tmp/ezdpl.log
