#!/bin/bash
# backend server names in haproxy.cfg must be unique.
# find matched server ip and port
#    server appserver012 10.0.1.75:80 check
#    server webserver028 10.0.1.93:8080 check
# iptables -A OUTPUT -d <ip> -p tcp --dport <port> -j DORP
# OR 
# iptables -D OUTPUT -d <ip> -p tcp --dport <port> -j DORP
# Write log file.

_time=`date +%F_%H%M%S`
_cfg_file="/etc/haproxy/haproxy.cfg"
_log_file="/opt/haproxy_switch_log/switch.log"
_backend_server=$1
_oper=$2

set -e
set -u

if [[ -z $_backend_server ]] || [[ -z $_oper ]]; then
    echo "backend-switch <server_name> <on>	Switch On"
    echo "backend-switch <server_name> <off>	Switch Off"
    echo 
    echo "Backend servers:"
    sed 's/\t/ /g' $_cfg_file|grep -E "^ *server|^ *# *server"
    iptables -nvL OUTPUT
    exit 0
fi
    
echo -en "$_time\tNET\t$_backend_server\t$_oper\t" >> $_log_file
_match=`grep -w "server.*$_backend_server" $_cfg_file|awk '{print $3}'`
if [[ -z $_match ]]; then
   echo "backend server does not exist." | tee -a $_log_file
   exit 1
fi

_ip=`echo $_match   | awk -F: '{print $1}'`
_port=`echo $_match | awk -F: '{print $2}'`
case $_oper in
    on)
        if iptables -nvL OUTPUT |grep $_ip|grep $_port|grep DROP &>/dev/null; then
            iptables -D OUTPUT -d $_ip -p tcp --dport $_port -j DROP
	    echo -e  "OK" | tee -a $_log_file
 	else
	    echo -e  "Already ON" | tee -a $_log_file
        fi
        ;;
    off)
        if ! iptables -nvL OUTPUT |grep $_ip|grep $_port|grep DROP &>/dev/null; then
            iptables -A OUTPUT -d $_ip -p tcp --dport $_port -j DROP
	    echo -e  "OK" | tee -a $_log_file
 	else
	    echo -e  "Already OFF" | tee -a $_log_file
        fi
        ;;
    *)
        echo "Only on/off is valid." | tee -a $_log_file
        exit 1
        ;;
esac

