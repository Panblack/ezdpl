#!/bin/bash
source /usr/local/bin/release.include
_oper=$1
_usage="workerman.chat.sh u	Start
workerman.chat.sh d	Stop
workerman.chat.sh s	Status"
case $_oper in 
    u)
	echo "Regitster" ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_register.php       start -d &
	echo "Web"       ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_web.php            start -d &
	echo "Gateway"   ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_gateway.php        start -d &
	echo "Business"  ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_businessworker.php start -d &
	sleep 1
	echo "Workerman Started."
	;;
    d)
	echo "Regitster" ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_register.php       stop &
	echo "Web"       ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_web.php            stop &
	echo "Gateway"   ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_gateway.php        stop &
	echo "Business"  ;/usr/local/bin/php ${_PHP_ROOT}/workerman-chat/Applications/Chat/start_businessworker.php stop &
	sleep 1
	echo "Workerman Stoped."
	;;
    s)
	ps aux|grep --color=always 'WorkerMan:'|grep -v grep
	;;
    *)
	echo "$_usage"
	;;
esac

