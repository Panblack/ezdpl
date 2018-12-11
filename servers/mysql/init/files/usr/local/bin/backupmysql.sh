#!/bin/bash
source /usr/local/bin/release.include
if [[ -n $1 ]]; then
    _databases=$1
else
    _databases=$_MYSQL_DATABASES
fi
if [[ -n $2 ]]; then
    _dump_options=$2
else
    _dump_options=$_MYSQL_DUMP_OPTIONS
fi

_max_days=$_MYSQL_MAX_DAYS
if [[ -z $_max_days ]]; then
    _max_days=15
fi

_backup_path=$_MYSQL_BACKUP_PATH
if ! mkdir -p $_backup_path ; then
    _backup_path=$HOME
fi

_logfile="${_backup_path}/backupmysql.log"
touch $_logfile

_data_path=$_MYSQL_DATA_PATH
if [[ -z $_data_path ]]; then
    _data_path="/var/lib/mysql"
fi

_logbin=`cat /etc/my.cnf | egrep '^ *log_bin *=' | awk -F= '{print $2}' | tr -d [:blank:]`
if [[ -n $_logbin ]]; then
    _logbin_backup=Y
else
    _logbin_backup=N
fi

set -u
_start_date=`date +%F_%H%M%S`
echo "$_start_date Backupmysql started"    | tee -a $_logfile
echo "Databases    = $_databases"     | tee -a $_logfile
echo "DumpOptions  = $_dump_options"  | tee -a $_logfile
echo "MaxDays      = $_max_days"      | tee -a $_logfile
echo "BackupPath   = $_backup_path"   | tee -a $_logfile
echo "DataPath     = $_data_path"     | tee -a $_logfile
echo "LogFile      = $_logfile"       | tee -a $_logfile
echo "LogbinBackup = $_logbin_backup" | tee -a $_logfile

for x in $_databases ; do
    _thedate=`date +%F_%H%M%S`; echo -n "$_thedate - " | tee -a $_logfile
    mysqldump --flush-logs --default-character-set=utf8 --opt --routines --hex-blob $_dump_options $x 2>>$_logfile |gzip > ${_backup_path}/${x}_${_thedate}.sql.gz
    _thedate=`date +%F_%H%M%S`; echo "$_thedate $x" | tee -a $_logfile
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
	    echo "$x ( $_logbin_date $_logbin_size ) Moved to $_backup_path" | tee -a $_logfile
	fi
    done
fi

_end_date=`date +%F_%H%M%S`
echo "$_end_date Backupmysql completed" | tee -a $_logfile

cd ${_backup_path} && find -name "*.sql.gz" -mtime +${_max_days} -delete ; find -name "${_logbin}.*" -mtime +${_max_days} -delete 
echo -e "Backup files older than ${_max_days} days deleted!\n\n" | tee -a $_logfile

