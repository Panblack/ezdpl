#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

if [[ -n $_LOCAL_REPO ]]; then
    mkdir -p /etc/yum.repos.d/backup
    mv -f /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/backup/
    echo "$_LOCAL_REPO" > /etc/yum.repos.d/local.repo
fi

# logrotate
/bin/cp -p /etc/logrotate.conf /etc/logrotate.conf.bak
sed -i 's/rotate 4/rotate 5200/g' /etc/logrotate.conf

# crontab 
if [[ -n $_CRON_FOR_ROOT ]];then
    echo "Cron for root..."
    if [[ ! -f /var/spool/cron/root ]]; then
    	touch /var/spool/cron/root
    fi
    sed -i /"ban_ssh"/d /var/spool/cron/root
    sed -i /"ntpdate"/d /var/spool/cron/root
    echo "$_CRON_FOR_ROOT" >> /var/spool/cron/root
    chmod 600 /var/spool/cron/root
fi

#selinux
if  [[ $_SELINUX_OFF = 1 ]];then
    echo "Selinux off..." 
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

# aliyun (ignore kernel,centos-release when `yum update`) 
if egrep "(mirrors.aliyuncs.com|mirrors.aliyun.com|mirrors.cloud.aliyuncs.com|mirrors.cloud.aliyun.com)" /etc/yum.repos.d/CentOS-Base.repo &>/dev/null ; then
    echo "Aliyun ignore kernel update..."
    cp -p /etc/yum.conf /etc/yum.conf.bak
    echo "exclude=kernel* centos-release*" >> /etc/yum.conf
fi

# prepare to install packages
for x in `ps aux|egrep -i 'yum' |grep -v grep|awk '{print $2}'`; do
    kill $x || kill -9 $x
done
yum clean all

# timezone and epel for centos

case $_RELEASE in
    CENTOS6)
        # timezone
	if [[ -n $_TIMEZONE_INFO ]] ;then
            /bin/cp /usr/share/zoneinfo/${_TIMEZONE_INFO} /etc/localtime
	fi
        # install epel
        if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
            rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
        fi
        ;;
    CENTOS7)
        # timezone
	if [[ -n $_TIMEZONE_INFO ]] ;then
            timedatectl set-timezone ${_TIMEZONE_INFO}
	fi
        # install epel
        if ! grep enabled=1 /etc/yum.repos.d/epel* ;then
            rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        fi
        ;;
    UBUNTU)
        # timezone
	if [[ -n $_TIMEZONE_INFO ]] ;then
            /bin/cp /usr/share/zoneinfo/${_TIMEZONE_INFO} /etc/localtime
	fi
        ;;
esac

yum -y install deltarpm
yum update -y
yum -y install yum-utils bc telnet dos2unix man nmap vim wget zip unzip ntpdate tree gcc iptraf nethogs dsniff tcpdump bind-utils lsof sysstat dstat iftop geoip htop iotop openssl openssl-devel openssh bash mailx lynx git net-tools psmisc rkhunter unhide supervisor tcptraceroute python-pip jq cloud-utils-growpart && echo "Packages installed..."

if [[ -n $_VIMRC ]]; then
    echo "$_VIMRC" > ~/.vimrc
    echo "$_VIMRC" > /etc/skel/.vimrc
fi

# iftoprc
if [[ -n $_IFTOPRC ]]; then
    echo "$_IFTOPRC" > ~/.iftoprc
    echo "$_IFTOPRC" > /etc/skel/.iftoprc
fi

# history record
if [[ $_HISTORY_RECORD = 1 ]]; then
    sed -i '/history/d' /etc/skel/.bash_logout
    mkdir -p /etc/skel/.history
    echo "history &>> ~/.history/.history.\`whoami\`.\`date +%F_%H%M\`.log" >> /etc/skel/.bash_logout
    
    mkdir -p ~/.history
    sed -i '/history/d' ~/.bash_logout 
    echo "history &>> ~/.history/.history.\`whoami\`.\`date +%F_%H%M\`.log" >>  ~/.bash_logout
fi

# python pip & tools
echo "upgrade pip & install python packages..."
pip install --upgrade pip
if [[ -n $_PIP_INSTALL ]]; then
    pip install $_PIP_INSTALL
fi
echo

if [[ -f /usr/sbin/iptraf-ng ]]; then 
    ln -sf /usr/sbin/iptraf-ng  /usr/sbin/iptraf
    ln -sf /var/log/iptraf-ng   /var/log/iptraf
fi

# Install rpms
if ls /opt/packages/*.rpm &>/dev/null; then
    cd /opt/packages
    yum localinstall *.rpm
fi

# Update the entire file properties database 
if [[ $_RKHUNTER_PROPUPD = 1 ]];then
    echo "rkhunter --propupd ..."
    rkhunter --propupd
    echo
fi

# sshd_config
_sshd_config="ClientAliveInterval 60
ClientAliveCountMax 1"
/bin/cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.`date +%Y%m%d_%H%M%S`
echo "$_sshd_config" >> /etc/ssh/sshd_config

echo "`date +%F_%T` common/init " >> /tmp/ezdpl.log
service sshd restart



