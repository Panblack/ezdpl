#!/bin/bash
# Determine ezdpl home
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    _last_dir=` echo "$_dir"|awk -F'/' '{print $NF}'`
    EZDPL_HOME=`echo "$_dir"|sed 's/\/'$_last_dir'//g'`
fi
echo "EZDPL_HOME : ${EZDPL_HOME}"

# Read servers
if [[ ! -f ${EZDPL_HOME}/conf/hosts.lst ]]; then
    echo "${EZDPL_HOME}/conf/hosts.lst does not exist.";exit 1
fi
if [[ -n $1 ]]; then
    _servers=`egrep -v '(^#|^$)' ${EZDPL_HOME}/conf/hosts.lst | grep $1`
else
    _servers=`egrep -v '(^#|^$)' ${EZDPL_HOME}/conf/hosts.lst` 
fi

# Confirm
echo "$_servers"
echo 
echo "Commands:"
egrep -v '^ *#' ${EZDPL_HOME}/conf/batch.include
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
    source ${EZDPL_HOME}/conf/batch.include
    echo
    ((_count++))
done
exit 0
