#!/bin/bash
# Some scripts may last a long time. But the cron job interval may be very short.
# Thus, you need to stop the script from running if previous job has not finished.
# We just need to create a pid file in /dev/shm/
# If the pid file contains a pid number, exit.
# Here we go.

# Define log file name
_log_file="/var/log/YOUR_JOB.log"

# Define pid file name
_pid_file="/dev/shm/YOUR_JOB.pid"

# Read the pid file
_running_pid=`cat $_pid_file 2>/dev/null`

if [[ -n $_running_pid ]] ;then
   echo " `date` Running pid $_running_pid ." | tee -a $_log_file
   exit 0
fi

# Update pidfile
echo $$ > $_pid_file

echo -e "\n======= Job Starts `date` =========\n" >> $_log_file

    # Here goes your script
    set -u


    set +u
    # The end of your script

echo -e "\n======= Job   Ends `date` =========\n" >> $_log_file

# Empty pidfile
echo "" > $_pid_file

