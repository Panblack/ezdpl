#!/bin/bash

# Install epel
if grep " 6." /etc/redhat-release ; then
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
fi
if grep " 7." /etc/redhat-release ; then
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi 

yum -y install telnet man vim wget zip unzip ntpdate tree gcc iptraf tcpdump bind-utils lsof sysstat iotop nmon htop openssl openssh bash
if [ "$?" = "0" ];then
   echo "Packages installed..."
fi

# No mail notification
sed -i /"unset MAILCHECK"/d /etc/profile 2>/dev/null
echo "unset MAILCHECK" >> /etc/profile 2>/dev/null
source /etc/profile

# Prompt '[ user@host time path ]# '
sed -i /"PS1="/d ~/.bash_profile
echo "PS1='[\\u@\\h \\t \\w]# '" >> ~/.bash_profile

# vim auto indent(Hit <F9> for proper pasting), q command replaced with :q
_vimrc="set nocompatible
set shiftwidth=4
filetype plugin indent on
set pastetoggle=<F9>
nnoremap q :q
nnoremap Q :q
"
echo "$_vimrc" > ~/.vimrc

echo
chkconfig crond on
service crond start
