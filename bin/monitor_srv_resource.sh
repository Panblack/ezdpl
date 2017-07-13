#!/bin/bash
# Monitoring all server resources, by panblack@126.com
# Requires: sqlezdpl, sendmail service

# Determine ezdpl home
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    cd $_dir && cd ..
    EZDPL_HOME=`pwd`
fi
echo "EZDPL_HOME : ${EZDPL_HOME}"

set -u
_mail_recever="receive@example.com"
_time_start=`date +%F_%T`
_log_file="/opt/report/mon/log.txt"
echo $_time_start >> $_log_file

# Read servers
if [[ -f ${EZDPL_HOME}/hosts.lst ]]; then
    _servers=`egrep -v '(^#|^$)' ./hosts.lst`
else
    source ${EZDPL_HOME}/batch.where.sh
    _SQL=" SELECT  ip , name , user , port , purpose FROM srv $_where "
    _servers=`./bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'purpose'`
fi

_mem_limit="95"
IFS=$'\n'
for x in $_servers;do
        _ip=`  echo $x|awk '{print $1}'`
        _host=`echo $x|awk '{print $2}'`
        _user=`echo $x|awk '{print $3}'`
        _port=`echo $x|awk '{print $4}'`
        _purpose=`echo $x|awk '{print $5}'`

        if [[ -z $_ip ]] || [[ -z $_port ]]; then
            continue
        fi
        [[ -z $_user ]] && _user=root

  	_str=$(ssh -p $_port $_user@$_ip "\
	cat /proc/cpuinfo|grep processor|wc -l;\
	echo -n '|';\
	uptime|grep 'load average';\
	echo -n '|';\
      	free -tm |grep "buffers/cache" ;\
	echo -n '|';\
	df -hTPl|egrep '(9.%|100%)';\
	echo -n '|';\
	mount|grep warning;")

	#Original str
	_mon_file="/opt/report/mon/${_host}.mon.log"
	echo -e "\n\n${_time_start}\n${_str}"|sed 's/|//g' >> $_mon_file

	#Extract data
	_cpu_count=`echo $_str|awk -F'|' '{print $1}'`
	((_cpu_count=$_cpu_count-1 ))
	_cpu_load=`echo $_str|awk -F'|' '{print $2}'|awk -F': ' '{print $2}'`
	_load_1=`echo $_cpu_load|awk -F', ' '{print $1}'`
	_load_5=`echo $_cpu_load|awk -F', ' '{print $2}'`
	_load_15=`echo $_cpu_load|awk -F', ' '{print $3}'`

	_mem_info=`echo $_str|awk -F'|' '{print $3}'`
	_mem_used=`echo $_mem_info |awk '{print $3}'`
	_mem_free=`echo $_mem_info |awk '{print $4}'`
	_mem_total=`echo $_mem_used + $_mem_free|bc`
	_mem_percent=`echo "scale=2;ibase=10;obase=10;$_mem_used/$_mem_total"|bc`
	_mem_percent=`echo "${_mem_percent}*100"|bc`
	
	_df=`echo $_str|awk -F'|' '{print $4}'`
	_mount_err=`echo $_str|awk -F'|' '{print $5}'`

	_message="${_host}"
	if [[ -n $_df ]]; then
	    _message="${_message}\nDisk Usage: ${_df}"
	fi

	if [[ `echo "$_load_5 > $_cpu_count"|bc` -eq 1 ]] || [[ `echo "$_load_5 > $_cpu_count"|bc` -eq 1 ]] || [[ `echo "$_load_15 > $_cpu_count"|bc` -eq 1 ]]; then
	    _message="${_message}\nCPU load: ${_cpu_load}"
	fi

	# test servers memory usage not included.
        if [[ $_mem_percent > $_mem_limit ]] && [[ $_host != "testsrv.example.com" ]] && [[ $_host != "testsrv2.example.com" ]]; then
	    _message="${_message} \nMem Usage: ${_mem_percent}% \nMem Info: ${_mem_info}" 
	fi

	if [[ -n $_mount_err ]]; then
	    _message="${_message}\nDisk Error: ${_mount_err}"
	fi

	#send email
        if [[ $_message != ${_host} ]]; then
	    echo -e "$_message" >> $_log_file
	    echo -e "$_message" | mailx -s "$_host Resource Warning" $_mail_recever
	fi
done

_time_end=`date +%F_%T`
echo -e "${_time_end}\n\n" >> $_log_file

