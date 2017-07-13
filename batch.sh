#!/bin/bash
# Determine ezdpl home
_dir=$(dirname `readlink -f $0`)
cd $_dir
echo "ezdplHome:`pwd`"

# Read servers
if [[ -f ./hosts.lst ]]; then
    _servers=`egrep -v '(^#|^$)' ./hosts.lst`
else
    source ./batch.where.sh
    _SQL=" SELECT  ip , name , user , port , purpose FROM srv $_where "
    _servers=`./bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'purpose'`
fi

# Confirm
echo "$_servers"
echo 
echo "Where:"
egrep -v '(^#|^$)' ./batch.where.sh
echo 
echo "Commands:"
egrep -v '^ *#' ./batch.include.sh
echo
read -p "Press Y to continue:" _go
if [[ $_go != Y ]]; then
    exit 0
fi

# Start batch jobs
_count=1
IFS=$'\n'
for x in $_servers ; do
    _ip=`  echo $x|awk '{print $1}'`
    _host=`echo $x|awk '{print $2}'`
    _user=`echo $x|awk '{print $3}'`
    _port=`echo $x|awk '{print $4}'`
    _purpose=`echo $x|awk '{print $5}'`
    echo "$_count [ $_ip , $_user@$_host:$_port , $_purpose ]"
    source ./batch.include.sh
    echo
    ((_count++))
done
exit 0
