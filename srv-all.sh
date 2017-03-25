#!/bin/bash

source srv-all.where
_SQL=" SELECT name , port FROM srv $_where"

_servers=`/opt/ezdpl/bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'name'`
IFS="
"
for x in $_servers ; do
   _host=`echo $x|awk -F"\t" '{print $1}'`
   _port=`echo $x|awk -F"\t" '{print $2}'`
  
   echo [ $_host : $_port ]
   source srv-all.include
   echo;echo
done
