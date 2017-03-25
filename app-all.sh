#!/bin/bash
source app-all.where.sh
_SQL=" SELECT srvname , port , webname FROM v_srvweb $_where "

_servers=`/opt/ezdpl/bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'name'`
echo "$_servers"
echo 
IFS="
"
for x in $_servers ; do
  _host=`echo $x|awk -F"\t" '{print $1}'`
  _port=`echo $x|awk -F"\t" '{print $2}'`
  _web=` echo $x|awk -F"\t" '{print $3}'`

  echo [ $_host : $_port : $_web]
  source ./app-all.include.sh
  echo

done

