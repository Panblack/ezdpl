#!/bin/bash
_log_file="/var/log/clamav.`date +%F`.log"
_path_to_move="/tmp/clamav_infected"
touch $_log_file
if [[ -z $1 ]]; then
    echo "Usage: clamav.sh <path> [update(y)]]";exit
else
    echo -e "\n`date +%F_%T`" | tee -a $_log_file
    _target=$1
    if [[ ! -e $_target ]]; then
	echo "$_target does not exist." | tee -a $_log_file ; exit 1
    fi
fi
if [[ $2 = y ]]; then
    _update=Y
else
    _update=N
fi
echo -e "Target = `readlink -f $_target`\nUpdate = $_update" | tee -a $_log_file
if [[ $_update = Y ]]; then
    yum update -y clamav    | tee -a $_log_file 
    freshclam               | tee -a $_log_file
fi
echo "Scan starts..."       | tee -a $_log_file
clamscan --suppress-ok-results --stdout --infected --recursive --max-filesize=512M \
         --cross-fs=no --scan-archive=yes --block-encrypted=yes --follow-dir-symlinks=1 \
         --follow-file-symlinks=1 --block-encrypted=yes --move="$_path_to_move" --log="$_log_file" \
	 $_target
echo -e "Infected:\n`/bin/ls -lh --color=auto --time-style=long-iso $_path_to_move 2>/dev/null`" | tee -a $_log_file
echo -e "`date +%F_%T`\n"   | tee -a $_log_file
