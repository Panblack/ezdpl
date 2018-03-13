#!/bin/bash
# get EZDPL_HOME
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    _last_dir=` echo "$_dir"|awk -F'/' '{print $NF}'`
    EZDPL_HOME=`echo "$_dir"|sed 's/\/'$_last_dir'//g'`     
fi

# get _BASES_DIR 
source ${EZDPL_HOME}/conf/ezdpl.include

# get _NOTIFY_SENDER _NOTIFY_SENDER_USER _NOTIFY_SENDER_PASS _NOTIFY_SENDER_SMTP _NOTIFY_RECEIVERS
source ${EZDPL_HOME}/conf/japp.include

######## Start of preparation ########
_script=`echo "$0"|awk -F'/' '{print $NF}'`
_log_dir="/opt/report/${_script}"
_log_file=${_log_dir}/${_script}.`date +%F`.log
mkdir -p $_log_dir
touch $_log_file

_pid_file="/dev/shm/${_script}.pid"
if [[ -f $_pid_file ]]; then
    _existing_pid=`cat $_pid_file 2>/dev/null`
   if [[ -n $_existing_pid ]] ;then
       echo " `date +%F_%T` Existing pid $_existing_pid" | tee -a $_log_file
       exit 0
   fi
fi
echo $$ > $_pid_file
set -u;set -E;set -T
trap "mv -f $_pid_file "/tmp/${_script}.pid.`date +%F_%H%M%S`" 2>/dev/null ; exit" ERR EXIT SIGQUIT SIGHUP SIGINT SIGKILL SIGTERM
######## End of preparation ########

# Job Starts ...
echo -e "`date +%F_%T` START" | tee -a $_log_file
_notify_sender_pass=`echo $_NOTIFY_SENDER_PASS|base64 -d`
_webs=`cat ${EZDPL_HOME}/conf/webservers.lst|egrep -v '^ *#'`
IFS=$'\n'
for x in $_webs; do		# webs
	_web=`        echo $x|awk -F'|' '{print $1}'`
	_server_ip=`  echo $x|awk -F'|' '{print $2}'`
	_server_user=`echo $x|awk -F'|' '{print $3}'`
	_server_port=`echo $x|awk -F'|' '{print $4}'`
    
    	_wars=`cat ${EZDPL_HOME}/conf/war.lst|egrep -v "^ *#"|awk -F'|' '{if ($4 == "'$_web'") print $2}'`
	echo -e "Web:\t${_web}\nServer:\t${_server_user}@${_server_ip}:${_server_port}" | tee -a $_log_file

    	# Check tomcat bases
	_base_check=`ssh -p${_server_port} ${_server_user}@${_server_ip} "/usr/local/bin/psj"`
	_server_hostname=`ssh -p${_server_port} ${_server_user}@${_server_ip} "hostname -s"`
    	if ! echo "$_base_check"|grep "\-Dcatalina.base"|egrep "${_BASES_DIR}/${_web}" &>/dev/null; then
	    _notify_title="${_server_hostname}:${_web}"
	    _notify_content="`date +%F_%T` $_base_check"
	    ssh -p${_server_port} ${_server_user}@${_server_ip} "/usr/local/bin/tmc ${_web} up " >> $_log_file
	    echo -e "\n\n${_notify_title}\n${_notify_content}\nSending notify email" | tee -a $_log_file
	    /usr/local/bin/pymail.py -f "$_NOTIFY_SENDER" -t "$_NOTIFY_RECEIVERS" -s "$_NOTIFY_SENDER_SMTP" \
		-u "$_NOTIFY_SENDER_USER" -p "$_notify_sender_pass" -S "${_notify_title} down" -m "${_notify_content}" 
	    echo -e "${_notify_content} \n ${_notify_title} started. Email sent.\n" | tee -a $_log_file
	    continue
    	fi

	# Check tomcat work dir 
        for z in $_wars; do 	# wars
	    echo -e "War:\t$z" | tee -a $_log_file
	    _webapp_temp_dir="${_BASES_DIR}/${_web}/work/Catalina/localhost/${z}"
	    if ! ssh -p${_server_port} ${_server_user}@${_server_ip} "ls $_webapp_temp_dir &>/dev/null" ; then
		ssh -p${_server_port} ${_server_user}@${_server_ip} "mkdir -p $_webapp_temp_dir" 
	    	_notify_title="${_server_hostname}:${_web} work dir for ${z} missing"
	    	_notify_content="`date +%F_%T` ${_server_hostname}:${_webapp_temp_dir}"
	        /usr/local/bin/pymail.py -f "$_NOTIFY_SENDER" -t "$_NOTIFY_RECEIVERS" -s "$_NOTIFY_SENDER_SMTP" \
		    -u "$_NOTIFY_SENDER_USER" -p "$_notify_sender_pass" -S "${_notify_title}" -m "${_notify_content}" 
	    	echo -e "${_notify_content} created. Email sent." | tee -a $_log_file
	    fi
        done	# wars
	echo | tee -a $_log_file
    unset x
done		# webs
echo -e "`date +%F_%T` END\n\n" | tee -a $_log_file
# Job Ends ...

# Delete pidfile
rm $_pid_file -f 2>/dev/null
