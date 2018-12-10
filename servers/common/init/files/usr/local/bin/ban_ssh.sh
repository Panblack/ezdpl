#! /bin/bash
cat /var/log/secure|awk '/Failed password/{print $(NF-3)}' |sort|uniq -c|sort -n  > /var/log/black.list
cat /var/log/secure|awk '/Failed publickey/{print $(NF-5)}'|sort|uniq -c|sort -n >> /var/log/black.list
if [[ `date +%d` = 01 ]] && [[ `date +%H` = 01  ]] ;then
  sed -i /"deny"/d /etc/hosts.deny 
fi

IFS="
"
for i in `cat  /var/log/black.list`; do
  NUM=`echo $i|awk '{print $1}'`
  IP=`echo $i |awk '{print $2}'`
  # if length of $NUM is greater than 1 
  if [ ${#NUM} -gt 1 ]; then
    if ! grep $IP /etc/hosts.deny > /dev/null ; then
      echo "sshd:$IP:deny" >> /etc/hosts.deny
    fi
  fi
done
