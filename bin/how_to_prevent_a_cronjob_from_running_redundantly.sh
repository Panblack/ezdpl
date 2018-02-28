#!/bin/bash
# The right way to write a cronjob script, by panblack@126.com

# Sometimes a cron job lasts a long time while the interval is short. 
# To prevent it from being executed before last job finishes, you'll need some technique. 
# It's simple:
#   Store a pidfile in tmpfs. 
#   Check the pidfile before job really starts.
#   Delete the pidfile after job finishes successfully.
# Enjoy!
# Wait, what if the script does not finish successfully, and the pidfile holds the job forever?
# It is you who need to make sure the script finally finishes. Don't blame the pidfile ^_- 
# Also, we have `trap` command at hand...

# Keeping a log for a cron job is a good idea.

######## Start of preparation ########
_script=`echo "$0"|awk -F'/' '{print $NF}'`
_log_dir="/opt/report/${_script}"
_log_file=${_log_dir}/${_script}.`date +%F`.log
mkdir -p $_log_dir
touch $_log_file

# Check pidfile
_pid_file="/dev/shm/${_script}.pid"
if [[ -f $_pid_file ]]; then
    _existing_pid=`cat $_pid_file 2>/dev/null`
   if [[ -n $_existing_pid ]] ;then
       echo " `date +%F_%T` Existing pid $_existing_pid" | tee -a $_log_file
       exit 0
   fi
fi
# Update pidfile
echo $$ > $_pid_file
# Error control
set -u;set -E;set -T
trap "mv -f $_pid_file "/tmp/${_script}.pid.`date +%F_%H%M%S`" 2>/dev/null ; exit" ERR EXIT SIGQUIT SIGHUP SIGINT SIGKILL SIGTERM
######## End of preparation ########

# Job Starts ...
echo -e "`date +%F_%T` START"   | tee -a $_log_file


echo -e "`date +%F_%T` END\n\n" | tee -a $_log_file
# Job Ends ...

# Delete pidfile
rm $_pid_file -f 2>/dev/null

