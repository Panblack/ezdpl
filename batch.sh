#!/bin/bash
# Determine ezdpl home
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    cd $_dir
    EZDPL_HOME=`pwd`
fi
echo "EZDPL_HOME : ${EZDPL_HOME}"

# Read servers
if [[ -f ${EZDPL_HOME}/hosts.lst ]]; then
    _servers=`egrep -v '(^#|^$)' ./hosts.lst`
else
    source ${EZDPL_HOME}/batch.where.sh
    _SQL=" SELECT  ip , name , user , port , purpose FROM srv $_where "
    _servers=`./bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'purpose'`
fi

# Confirm
echo "$_servers"
echo 
echo "Where:"
egrep -v '(^#|^$)' ${EZDPL_HOME}/batch.where.sh
echo 
echo "Commands:"
egrep -v '^ *#' ${EZDPL_HOME}/batch.include.sh
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
    if [[ -z $_ip ]] || [[ -z $_port ]]; then
        echo "Host/Port missing"
        continue
    fi
    [[ -z $_user ]] && _user=root

    echo "$_count [ $_ip , $_user@$_host:$_port , $_purpose ]"
    source ${EZDPL_HOME}/batch.include.sh
    echo
    ((_count++))
done
exit 0
