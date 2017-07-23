#!/bin/bash
set -u
_thedate=`date +%F_%H%M%S`
_mysqlpass=""
_databases="mysql "
_data_path="/data/mysql"
_backup_path="/data/backup"
_logfile="$_backup_path/mysqldump.log"
_logbin=`cat /etc/my.cnf | grep 'log_bin'|grep '=' |awk -F= '{print $2}'|tr -d [:blank:]`

echo "Start full backup $_thedate" >> $_logfile
for x in $_databases ; do
    mysqldump -u root -p"$_mysqlpass" --flush-logs --default-character-set=utf8 --opt --hex-blob $x 2>>$_logfile |gzip > ${_backup_path}/${x}_${_thedate}.sql.gz
done

# Move logbin files.
_yesterday=`date --date='yesterday' +%F`
cd $_data_path

for x in ${_logbin}.[0-9]* ;do 
    _logbin_date=`stat -c %y $x|awk '{print $1}'`
    _logbin_size=`stat -c %s $x`
    if [[ $_logbin_date < $_yesterday ]]; then
	/bin/mv -f $x ${_backup_path}/
	echo "$x ( $_logbin_date $_logbin_size ) Moved to $_backup_path" >> $_logfile
    fi
done

_enddate=`date +%F_%H%M%S`
echo -e "Backup Completed $_enddate \n\n" >> $_logfile

cd ${_backup_path} && find -name "*.sql.gz" -mtime +60 -delete ; find -name "${_logbin}.*" -mtime +7 -delete 
echo -e "Backup files older than 60 days deleted!"  >> $_logfile
echo  >> $_logfile
