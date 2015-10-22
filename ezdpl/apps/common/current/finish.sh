#!/bin/bash
#make it your script
#set -e

# /etc/profile
/bin/cp /etc/profile /etc/profile.bak
# Turn off mail check
chkmailcheck=$(cat /etc/profile |grep "unset MAILCHECK"|grep -v "#")
if [ ! -n "$chkmailcheck" ]; then
 echo "unset MAILCHECK" >> /etc/profile
fi
# make vim default
chkvim=$(cat /etc/profile |grep "alias vi='vim'"|grep -v "#")
if [ ! -n "$chkvim" ]; then
 echo "alias vi='vim'" >> /etc/profile
fi
# set LANG
chklang=$(cat /etc/profile |grep "export LANG=en_US.UTF-8"|grep -v "#")
if [ ! -n "$chklang" ]; then
  echo "export LANG=en_US.UTF-8" >> /etc/profile
fi
echo
echo "/etc/profile modified."
echo

# ll with long-iso date format
/bin/cp /etc/profile.d/colorls.sh /etc/profile.d/colorls.sh.bak
chkll=$(cat /etc/profile.d/colorls.sh |grep "alias ll='ls -l --color=auto --time-style=long-iso'"|grep -v "#")
if [ ! -n "$chkll" ]; then
  echo "alias ll='ls -l --color=auto --time-style=long-iso' 2>/dev/null" >> /etc/profile.d/colorls.sh
fi
echo
echo "/etc/profile.d/colorls.sh modified."
echo

# Selinux
sed 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config -i
echo
echo "/etc/selinux/config modified." 
echo

# disable cron mail
sed 's/MAILTO=root/MAILTO=""/g' /etc/crontab -i
echo
echo "/etc/crontab modified."
echo

# install/reinstall jdk
for x in $(rpm -qa|egrep "jdk|jre"); do 
 rpm -e --nodeps $x 
done
rpm -ivh  /tmp/jdk-7u75-linux-x64.rpm
echo
echo "jdk installed/reinstalled."
echo

# install necessary packages:
yum clean all
yum install zip unzip man vim tree ntpdate sysstat wget gcc tcpdump telnet bind-utils -y 
echo
echo "necessary packages installed. "
echo

# Finish
source /etc/profile
setenforce 0
chkconfig ip6tables off
chkconfig crond on
chkconfig iptables on
/etc/init.d/crond restart
/etc/init.d/iptables restart
/etc/init.d/network restart

echo
echo "services restarted."
echo
