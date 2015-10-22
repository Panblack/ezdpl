#!/bin/bash
if [ -n "$1" ]; then
  _app_version=$1
else
  echo "app/version required.  Exit!"
  exit 1
fi

if [ -n "$2" ]; then
  _reboot=$2
else
  _reboot=N
fi
if [ -n "$3" ]; then
  _username=$3
else
  _username=root
fi


if [ -f "./server.list" ]; then
  for x in `cat ./server.list`
    do ./ezdpl.sh Y $x $_app_version $_reboot $_username
  done
else
  echo "server.list required!"
  exit 1
fi
