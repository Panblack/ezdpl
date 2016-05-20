#!/bin/bash
set -u
_time_start=`date +%F_%T`
_log_file="/home/dpl/report/mon/log.txt"
echo $_time_start >> $_log_file

_servers=`cat server.list`
_swap_limit=".40"

    for x in $_servers;do
    	_host=`echo $x|awk -F'|' '{print $1}'`
    	_port=`echo $x|awk -F'|' '{print $2}'`

	#Gather info
  	_str=$(ssh root@$_host -p $_port "\
	cat /proc/cpuinfo|grep processor|wc -l;\
	echo -n '|';\
	uptime|grep 'load average';\
	echo -n '|';\
      	free -tmo|grep Swap|sed 's/Swap://g';\
	echo -n '|';\
	df -hTPl|egrep '(8.%|9.%|100%)';\
	echo -n '|';\
	mount|grep warning;")

	#Original string
	_mon_file="/home/dpl/report/mon/${_host}.mon.log"
	echo -e "\n\n${_time_start}\n${_str}"|sed 's/|//g' >> $_mon_file

	#Extract data
	_cpu_count=`echo $_str|awk -F'|' '{print $1}'`
	((_cpu_count=$_cpu_count-1 ))
	_cpu_load=`echo $_str|awk -F'|' '{print $2}'|awk -F': ' '{print $2}'`
	_load_1=`echo $_cpu_load|awk -F', ' '{print $1}'`
	_load_5=`echo $_cpu_load|awk -F', ' '{print $2}'`
	_load_15=`echo $_cpu_load|awk -F', ' '{print $3}'`
	_swap_total=`echo $_str|awk -F'|' '{print $3}'|awk '{print $1}'`
	_swap_used=`echo $_str|awk -F'|' '{print $3}'|awk '{print $2}'`
	_swap_percent=`echo "scale=2;ibase=10;obase=10;$_swap_used/$_swap_total"|bc`
	_df=`echo $_str|awk -F'|' '{print $4}'`
	_mount_err=`echo $_str|awk -F'|' '{print $5}'`

	_message="${_host}"
	if [[ -n $_df ]]; then
	    _message="${_message}\nDisk Usage: ${_df}"
	fi
	if [[ $_load_1 > $_cpu_count ]] || [[ $_load_5 > $_cpu_count ]] || [[ $_load_15 > $_cpu_count ]]; then
	    _message="${_message}\nCPU load: ${_cpu_load}"
	fi
        if [[ $_swap_percent > $_swap_limit ]]; then
	    _message="${_message}\nSwap Usage: `echo \"${_swap_percent}*100\"|bc`%"
	fi
	if [[ -n $_mount_err ]]; then
	    _message="${_message}\nDisk Error: ${_mount_err}"
	fi

	#to send email
        if [[ $_message != ${_host} ]]; then
	    echo -e "$_message" >> $_log_file
	    echo -e "$_message" | mailx -s "$_host Resource Warning" xuw@yaguit.com
	fi
    done

_time_end=`date +%F_%T`
echo -e "${_time_end}\n\n" >> $_log_file

