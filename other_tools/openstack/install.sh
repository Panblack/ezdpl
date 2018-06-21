#!/bin/bash
# This script prepares a Centos7 server to install OpenStack with 'packstack'.
# Written by panblack@126.com
# 2018/06/21
# net info
_netconn=`ip a |egrep '[1-9]: '|grep -v ': lo:'|awk -F': ' '{print $2}'|head -1`
_gateway=`ip route|grep "default via"|awk '{print $3}'`

# ip address
if [[ -z $1 ]];then
   _ip=`ip a show $_netconn|grep ' inet '|awk '{print $2}'|awk -F'/' '{print $1}'`
   _prefix=`ip a show $_netconn|grep ' inet '|awk '{print $2}'|awk -F'/' '{print $2}'`
else
   _ip="$1"
   _prefix="24"
fi

echo "Network info:"
echo "Connection: $_netconn"
echo "Ip address: $_ip"
echo "Prefix:     $_prefix"
echo "Gateway:    $_gateway"

# selinux
/bin/cp /etc/selinux/config /etc/selinux/config.bak
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
echo "selinux off"

# stop and disable firewalld
systemctl stop firewalld
systemctl disable firewalld
echo "firewalld off"

# sshd
/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "sshd configured and restarted"

# vimrc
if [[ -f /root/.vimrc ]]; then
    /bin/cp /root/.vimrc /root/.vimrc.bak
fi
echo -e "nnoremap q :q\nnnoremap Q :q!" > /root/.vimrc
echo "vimrc ok"

# update
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum update -y; yum install bridge-utils yum-utils deltarpm telnet dos2unix nmap vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils nethogs lsof sysstat dstat iftop geoip htop openssl openssl-devel openssh bash psmisc tcptraceroute -y
echo "yum updated"

# install packstack
echo "Preparing to install packstack..."
yum install -y centos-release-openstack-queens
yum install -y openstack-packstack

# bridging
systemctl enable network; systemctl stop NetworkManager; systemctl disable NetworkManager; systemctl mask NetworkManager
/bin/mv -f /etc/sysconfig/network-scripts/ifcfg-${_netconn} /etc/sysconfig/network-scripts/ifcfg-${_netconn}.bak

_ifcfg_br0="BOOTPROTO=static
DEVICE=br0
NAME=br0
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Bridge
IPADDR=$_ip
PREFIX=$_prefix
GATEWAY=$_gateway
DNS1=114.114.114.114
ZONE=public"

_ifcfg_eth="BOOTPROTO=none
DEVICE=$_netconn
NAME=$_netconn
NM_CONTROLLED=no
ONBOOT=yes
BRIDGE=br0"

echo "New network configs:"
echo "$_ifcfg_br0" > /etc/sysconfig/network-scripts/ifcfg-br0
echo "$_ifcfg_eth" > /etc/sysconfig/network-scripts/ifcfg-${_netconn}
systemctl restart network
echo
ip address show

echo "All done."
