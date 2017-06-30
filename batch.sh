#!/bin/bash
source ./batch.where.sh
case $1 in
    web)
	_SQL=" SELECT srvname , port , webname FROM v_srvweb $_where "
	;;
    all)
	_SQL=" SELECT name , port , purpose FROM srv $_where "
	;;
    *)
	echo "Usage: batch.sh <web|all>"
	exit 0
	;;
esac
_servers=`/opt/ezdpl/bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'name'`
echo "$_servers"
echo 
echo "Commands:"
egrep -v '^ *#' ./batch.include.sh
echo
echo "Where:"
cat ./batch.where.sh
echo 
read -p "Press Y to continue:" _go
if [[ $_go != Y ]]; then
    exit 0
fi

_count=1
IFS=$'\n'
for x in $_servers ; do
  _host=`echo $x|awk -F"\t" '{print $1}'`
  _port=`echo $x|awk -F"\t" '{print $2}'`
  _purpose=` echo $x|awk -F"\t" '{print $3}'`

  echo "$_count [ $_host : $_port : $_purpose ]"
  source ./batch.include.sh
  echo
  ((_count++))
done
exit 0
