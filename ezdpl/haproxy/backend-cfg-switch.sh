#!/bin/bash
# backend server names in haproxy.cfg must be unique.
# Backup haproxy.cfg
# Comment/Uncomment specific server-name in backend section
# Reload haproxy service.
# Write log file.

_time=`date +%F_%H%M%S`
_cfg_file="/etc/haproxy/haproxy.cfg"
_log_file="/opt/haproxy_switch_log/switch.log"
_backend_server=$1
_oper=$2
_match=`grep -w "server.*$_backend_server" $_cfg_file`
set -e
set -u
echo -en "$_time\tCFG\t$_backend_server\t$_oper\t" >> $_log_file
sed -i 's/\t/ /g' $_cfg_file
/bin/cp $_cfg_file /opt/haproxy_switch_log/haproxy.cfg.$_time
case $_oper in
off)
    if echo "$_match"|grep -v "#" ; then
	sed -i "/server.*$_backend_server /s/^/#/g" $_cfg_file && \
	service haproxy reload 
	echo -e  "OK" |tee -a  $_log_file
    else
	echo -e  "NO-OP" |tee -a  $_log_file
    fi
    ;;

on)
    if echo "$_match"|grep "#" ; then
	sed -i "/server.*$_backend_server /s/#//g" $_cfg_file && \
	service haproxy reload 
	echo -e  "OK" |tee -a  $_log_file
    else
	echo -e  "NO-OP" |tee -a  $_log_file
    fi
    ;;
*)
    echo "backend-cfg-switch <server_name> <on>  Switch On"
    echo "backend-cfg-switch <server_name> <off> Switch Off"
    echo 
    echo "Backend servers:"
    grep -E "^ *server|^ *# *server" $_cfg_file
    ;;
esac

exit 0

