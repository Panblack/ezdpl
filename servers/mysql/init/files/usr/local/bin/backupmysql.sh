#!/bin/bash
set -u
_thedate=`date +%F_%H%M%S`
_backuppath="/data/backup"
_logfile="$_backuppath/mysqldump.log"
_mysqlpass=""
echo "Start full backup $_thedate" >> $_logfile
for x in mysql ; do
  if [[ $x = db_with_blob_field ]]; then
    mysqldump -u root -p ${_mysqlpass} --flush-logs --default-character-set=utf8 --opt --hex_blob  db_with_blob_field 2>>$_logfile |gzip > ${_backuppath}/db_with_blob_field_${_thedate}.sql.gz
  else
    mysqldump -u root -p ${_mysqlpass} --flush-logs --default-character-set=utf8 --opt $x 2>>$_logfile |gzip > ${_backuppath}/${x}_${_thedate}.sql.gz
  fi
done

# Move logbin files.
_yesterday=`date -d yesterday +%F`
cd /data/mysql/
for z in logbin.0* ;do 
    _logbin_date=`stat -c %y $z|awk '{print $1}'`
    _logbin_size=`stat -c %s $z`
    if [[ $_logbin_date < $_yesterday ]]; then
	/bin/mv -f $z ${_backuppath}/
	echo "$z ( $_logbin_date $_logbin_size ) Moved to $_backuppath" >> $_logfile
    fi
done

_enddate=`date +%F_%H%M%S`
echo -e "Backup Completed $_enddate \n\n" >> $_logfile

cd ${_backuppath} && find -name "*.sql.gz" -mtime +60 -delete ; find -name "logbin.*" -mtime +7 -delete 
echo -e "Backup files older than 60 days deleted!"  >> $_logfile
echo  >> $_logfile
