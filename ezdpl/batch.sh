#!/bin/bash
IFS="
"
for x in `cat ./server.list`;do
  _host=`echo $x|awk -F':' '{print $1}'|sed 's/ //g'`
  _port=`echo $x|awk -F':' '{print $2}'|sed 's/ //g'`
  if [ ${#_port} -eq 0 ]; then
    _port="22"
  fi
  echo [ $_host $_port ]
  ssh root@$_host -p $_port ls -l
  #sh ezdpl Y $_host:$_port appsrv/mark
done

