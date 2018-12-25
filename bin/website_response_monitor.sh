#!/bin/bash
# get EZDPL_HOME
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    _last_dir=` echo "$_dir"|awk -F'/' '{print $NF}'`
    EZDPL_HOME=`echo "$_dir"|sed 's/\/'$_last_dir'//g'`
fi
echo "EZDPL_HOME=$EZDPL_HOME"

#scheme|target|port|path
_targets=`egrep -v '^ *#' ${EZDPL_HOME}/conf/websites.lst`
_log_file="/var/log/website_response_monitor.log"
if ! touch $_log_file; then
    _log_file="$HOME/website_response_monitor.log"
    touch $_log_file
fi
date +%F_%T | tee -a $_log_file
IFS=$'\n'
for x in $_targets ;do
    _scheme=`echo $x|awk -F'|' '{print $1}'` 
    _target=`echo $x|awk -F'|' '{print $2}'` 
    _port=`  echo $x|awk -F'|' '{print $3}'`
    _path=`  echo $x|awk -F'|' '{print $4}'`
    case $_scheme in 
        https|http)
            if [[ -n $_port ]]; then
                _url="${_scheme}://${_target}:${_port}"
            else
                _url="${_scheme}://${_target}"
            fi
	    if [[ -n $_path ]]; then
		_url="${_url}${_path}"
	    fi

            echo -n "`date +%T.%N` "            | tee -a $_log_file
            echo -n " $_url "                   | tee -a $_log_file
            echo "`curl -s -I $_url|grep HTTP`" | tee -a $_log_file
            echo "`date +%T.%N`"                | tee -a $_log_file
            ;;
        tcp)
            nc -zv  $_target $_port 2>&1        | tee -a $_log_file
            ;;
        udp)
            nc -uzv $_target $_port 2>&1        | tee -a $_log_file
            ;;
        *)
            echo "Scheme $_scheme not valid."   | tee -a $_log_file
            ;;
    esac
    echo    | tee -a $_log_file
done
date +%F_%T | tee -a $_log_file
echo        | tee -a $_log_file
echo        | tee -a $_log_file
