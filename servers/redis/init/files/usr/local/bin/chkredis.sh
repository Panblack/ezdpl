#!/bin/bash
echo -en "`date +%F_%T`\t" >> /var/log/chkredis.log
if ! ps aux|grep -v grep|egrep '(redis-server|:6379)' >> /var/log/chkredis.log ; then
    /usr/local/bin/redis.sh 6379 up >> /var/log/chkredis.log
fi
