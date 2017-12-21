#!/bin/bash
set -u
_max_days=30
_backup_path="/data/backupmysql/m"
_mysqlpass=""
_databases="User_DB mysql"
_data_path="/data/mysql"
_logfile="$_backup_path/mysqldump.log"
_logbin=`cat /etc/my.cnf | grep 'log_bin'|grep '=' |awk -F= '{print $2}'|tr -d [:blank:]`

for x in $_databases ; do
    if [[ $x = Very_Big_DB ]] ; then
	if [[ `date +%H` = 23 ]] ;then 
	    _thedate=`date +%F_%H%M%S`; echo "Start full backup $x $_thedate" >> $_logfile
    	    mysqldump --flush-logs --default-character-set=utf8 --opt --hex-blob $x 2>>$_logfile |gzip > ${_backup_path}/${x}_${_thedate}.sql.gz
	    _thedate=`date +%F_%H%M%S`; echo "End   full backup $x $_thedate" >> $_logfile
	fi
    else
	_thedate=`date +%F_%H%M%S`; echo "Start full backup $x $_thedate" >> $_logfile
    	mysqldump --flush-logs --default-character-set=utf8 --opt --hex-blob $x 2>>$_logfile |gzip > ${_backup_path}/${x}_${_thedate}.sql.gz
	_thedate=`date +%F_%H%M%S`; echo "End   full backup $x $_thedate" >> $_logfile
    fi
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
echo -e "Backup Completed $_enddate " >> $_logfile

cd ${_backup_path} && find -name "*.sql.gz" -mtime +${_max_days} -delete ; find -name "${_logbin}.*" -mtime +${_max_days} -delete 
echo -e "Backup files older than ${_max_days} days deleted!\n\n"  >> $_logfile
