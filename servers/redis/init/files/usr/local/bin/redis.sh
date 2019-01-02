#!/bin/bash
# Redis Multi Instance Service Script
# redis home:	/opt/redis-<port_num> ( e.g. /opt/redis-6379, /opt/redis-6380 ...)
# binaries:	/opt/redis-<port_num>/bin
# utils:	/opt/redis-<port_num>/utils
# config file:	/opt/redis-<port_num>/<port_num>.conf
# 

_port=$1
_oper=$2
_password=$3

set -u
_redis_instance="redis-${_port}"
_redis_home="/opt/$_redis_instance"
_redis_log="/var/log/${_redis_instance}.log"

funRedisPs() {
  netstat -antp |grep redis-server |sort -k6,7
#  ss -antp |grep redis-server  
}

funUsage() {
  echo
  echo "Usage: redis <port> <up|down|client|info>"
  echo "Available ports: 6379, 6380."
  echo
}

if [[ -z $_port ]]; then
    funUsage
    funRedisPs
    exit 0
fi

if [[ ! -d $_redis_home ]]; then
    echo -e "\033[31m redis instance not found. \033[0m"
    funUsage
    exit 1
fi

_pid=`ps aux | grep $_redis_instance | grep -v grep | awk '{print $2}'`

case $_oper in 
   up)
     if [[ -n $_pid ]] ; then
	 echo "redis $_port already started. Pid: $_pid"
	 echo
	 exit 1
     fi
     if $_redis_home/bin/redis-server $_redis_home/${_port}.conf > $_redis_log 2>&1 
     then
	 echo "OK"
     else
	 echo "ERROR. See log: $_redis_log"
     fi
     ;;
   down)
     if [[ -z $_pid ]]; then
     	 echo "redis $_port not running."
    	 exit 1
     fi
     if ! kill $_pid ; then
	 kill -9 $_pid
	 echo "Force kill engaged."
     fi
     ;;
   client)
     echo $_redis_home  
     if [[ -n $_password ]]; then
         $_redis_home/bin/redis-cli -p $_port -a $_password
     else
	 $_redis_home/bin/redis-cli -p $_port
     fi
     exit 0
     ;;
   info)
     echo $_redis_home  
     $_redis_home/bin/redis-cli -p $_port info
     exit 0
     ;;
   *)
     funUsage
     exit 1
     ;;
esac

for ((i=1;i<=3;i++));do echo -n "." ;sleep 1 ;done ;echo
funRedisPs

