#!/bin/bash
# Auto deploy java web apps, by panblack@126.com
# Requires: deployWeb scon 
# Need to be configured as a cron job: */1 * * * * 

fun_restore() {
  # restore remote server's config file 
  /opt/ezdpl/bin/scon $_remote_server e "mkdir -p $_remote_path"
  /opt/ezdpl/bin/scon $_remote_server u "$_config_file" "$_remote_path"
  /opt/ezdpl/bin/scon $_log_file      u "$_config_file" "$_remote_path"
}

# Main
# Base variables
_remote_server="testsrv.example.com"
_remote_path="/opt/wars/prod"
_oper_path="/opt/wars"
_config_file="$_oper_path/prod/config"
_log_file="$_oper_path/prod/deploy.log"
_datetime=`date +%F_%T`

if [[ $1 = 'r' ]];then
    fun_restore
    exit 0
fi

set -u 

# read remote server's config file:
## deploy=1
## prod=1
## wars=portal weixin
_config=`/opt/ezdpl/bin/scon $_remote_server e "cat $_remote_path/config" `
if ! echo "$_config" | grep 'deploy=1' | grep -v '#' &>/dev/null ; then
    echo "Deploy disabled."
    exit 0
fi
if ! echo "$_config" | grep 'prod=1' | grep -v '#' &>/dev/null ; then
    echo "prod NOT set."
    exit 0
fi
_wars=`echo "$_config" | grep 'wars=' | grep -v ^# |awk -F= '{print $2}' `

# Next, wars must be configured.
if [[ -z $_wars ]]; then
    echo -e "n $_datetime No wars configured. \n" | tee -a $_log_file
    fun_restore
    exit 0
fi

# Check pidfile
_pid_file="/dev/shm/$0.pid"
if [[ -f $_pid_file ]]; then
    _existing_pid=`cat $_pid_file 2>/dev/null`
   if [[ -n $_existing_pid ]] ;then
       echo " `date +%F_%T` Existing pid $_existing_pid ." | tee -a $_log_file
       exit 0
   fi
fi

# Update pidfile
echo $$ > $_pid_file

# Ready to deploy....
echo -e "-------- Production autoDeploy Start     $_datetime --------" | tee -a $_log_file
echo -e "\nPid:$$ \nWars:$_wars \nSource:$_remote_server:$_remote_path"  | tee -a $_log_file
ssh  root@$_remote_server "ls -ltr --time-style=long-iso $_remote_path/*.war " | tee -a $_log_file
echo | tee -a $_log_file

/opt/ezdpl/bin/deployWeb "$_wars" | tee -a $_log_file

_datetime=`date +%F_%T`
echo -e "======== Production autoDeploy Finished  $_datetime =========\n\n" | tee -a $_log_file
fun_restore

# Delete pidfile
rm $_pid_file -f 2>/dev/null
