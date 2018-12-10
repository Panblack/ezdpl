#! /bin/bash
grep 'pam_unix(vsftpd:auth): authentication failure' /var/log/secure|awk -F'rhost=' '{print $2}'|awk '{print $1}'|sort|uniq -c|sort -n > /var/log/black.list.ftp
if [[ `date +%d` = 01 ]] && [[ `date +%H` = 01  ]] ;then
  sed -i /"deny"/d /etc/hosts.deny 
fi

IFS="
"
for i in `cat  /var/log/black.list.ftp`; do
  NUM=`echo $i|awk '{print $1}'`
  IP=`echo $i |awk '{print $2}'`
  # if length of $NUM is greater than 1 
  if [ ${#NUM} -gt 1 ]; then
    if ! grep $IP /etc/hosts.deny > /dev/null ; then
      echo "vsftpd:$IP:deny" >> /etc/hosts.deny
    fi
  fi
done
#/var/log/secure-20181105:Nov  2 16:52:40 ygit vsftpd[28436]: pam_unix(vsftpd:auth): authentication failure; logname= uid=0 euid=0 tty=ftp ruser=ftpu rhost=116.3.201.240  user=ftpu


