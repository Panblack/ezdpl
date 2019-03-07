#! /bin/bash
cat /var/log/secure|awk '/Failed password/{print $(NF-3)}'  >  /dev/shm/black.lst
cat /var/log/secure|awk '/Failed publickey/{print $(NF-5)}' >> /dev/shm/black.lst
cat /var/log/secure|awk '/Invalid user/{print $(NF-2)}'     >> /dev/shm/black.lst
cat /var/log/secure|awk '/maximum authentication attempts exceeded for/{print $(NF-4)}' >> /dev/shm/black.lst
sort /dev/shm/black.lst|uniq -c|sort -h > /var/log/black.list
if [[ `date +%d` = 01 ]] && [[ `date +%H` = 01  ]] ;then
  sed -i /"deny"/d /etc/hosts.deny 
fi

IFS=$'\n'
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
