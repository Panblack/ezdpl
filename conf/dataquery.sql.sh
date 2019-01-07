
# for dataquery
funDataQuery() {
_default_db=mydb

case $_oper in 
    stat)
    	echo 
    	echo "Data table TOP 12："
    	_sql="
    SELECT table_schema, table_name,FORMAT(table_rows,0) AS rows FROM INFORMATION_SCHEMA.TABLES WHERE table_schema='$_default_db' ORDER BY table_rows DESC LIMIT 12;"
    	funSql $_default_db "$_sql"; echo
    	;;

    *)
    	echo "
Usage: 
dataquery stat			table stat and critical table data.
"
    	;;

esac
}

