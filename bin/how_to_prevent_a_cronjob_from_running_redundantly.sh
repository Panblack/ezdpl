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


# Keeping a log for a cron job is a good idea.
_log_file="/tmp/$0.log"
if [[ ! -f $_log_file ]]; then
    touch $_log_file
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

# Job Starts ...


# Job Ends ...

read -p "Enter!"

# Delete pidfile
rm $_pid_file -f 2>/dev/null

