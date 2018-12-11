#!/bin/bash
source /usr/local/bin/release.include
if [[ -n $1 ]]; then
    _databases=$1
else
    _databases=$_MYSQL_DATABASES
fi
if [[ -n $2 ]]; then
    _ignore_tables=$2
else
    _ignore_tables=$_MYSQL_IGNORE_TABLES
fi

_max_days=$_MYSQL_MAX_DAYS
_backup_path=$_MYSQL_BACKUP_PATH
_data_path=$_MYSQL_DATA_PATH
_logfile="${_backup_path}/mysqldump.log"

_logbin=`cat /etc/my.cnf | grep 'log_bin'|grep '=' |awk -F= '{print $2}'|tr -d [:blank:]`
if [[ -n $_logbin ]]; then
    _logbin_backup=Y
else
    _logbin_backup=N
fi

set -u
touch $_logfile
echo -e "Databases=$_databases\nIgnoreTables=$ignore_tables\nMaxDays=$_max_days\nBackupPath=$_backup_path\nDataPath=$_data_path\nLogFile=$_logfile\nLogbinBackup=$_logbin_backup" | tee -a $_logfile

for x in $_databases ; do
    _thedate=`date +%F_%H%M%S`; echo "Start full backup $x $_thedate" >> $_logfile
    mysqldump --flush-logs --default-character-set=utf8 --opt --routines --hex-blob $_ignore_tables $x 2>>$_logfile |gzip > ${_backup_path}/${x}_${_thedate}.sql.gz
    _thedate=`date +%F_%H%M%S`; echo "End   full backup $x $_thedate" >> $_logfile
done

# Move logbin files.
if [[ $_logbin_backup = Y ]]; then
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
fi

_enddate=`date +%F_%H%M%S`
echo -e "Backup Completed $_enddate " >> $_logfile

cd ${_backup_path} && find -name "*.sql.gz" -mtime +${_max_days} -delete ; find -name "${_logbin}.*" -mtime +${_max_days} -delete 
echo -e "Backup files older than ${_max_days} days deleted!\n\n"  >> $_logfile

