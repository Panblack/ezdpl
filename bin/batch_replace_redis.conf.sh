#!/bin/bash
# /opt/redis-6379 /opt/redis-6380 /opt/redis-6381 ...
for x in redis-6*; do _port=`echo $x|awk -F'-' '{print $2}'`; sed -i 's/port 6379/port '$_port'/g' ${x}/redis.conf; done
for x in redis-6*; do _port=`echo $x|awk -F'-' '{print $2}'`; sed -i 's/daemonize no/daemonize yes/g' ${x}/redis.conf; done
for x in redis-6*; do _port=`echo $x|awk -F'-' '{print $2}'`; sed -i 's#pidfile /var/run/redis_6379.pid#pidfile /opt/'$x'/redis.pid#g' ${x}/redis.conf; done
for x in redis-6*; do _port=`echo $x|awk -F'-' '{print $2}'`; mv $x/redis.conf $x/${_port}.conf;done
