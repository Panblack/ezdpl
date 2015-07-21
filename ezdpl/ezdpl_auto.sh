#!/bin/bash
# ezdpl.sh in silent mode
# variables
_ipaddress=$1
_app_version=$2
if [ -n "$3" ]; then
  _reboot=$3
fi
if [ -n "$4" ]; then
  _username=$4
else
  _username="root"
fi

# Check
if [ ! -d "./apps/$_app_version" ]; then
  echo
  echo "There is no $_app_version configured here !"
  exit 1
fi

chkaccess=`ssh $_username@$_ipaddress ls -d /opt`
if [ ! -n "$chkaccess" ]; then
  echo
  echo "$_ipaddress is not reachable. "
  exit 1
fi

# Start copy app/version 
scp -r ./apps/$_app_version/* $_username@$_ipaddress:/

# Run runme.sh on the target server
if [ -f "./apps/$_app_version/runme.sh" ]; then
  ssh $_username@$_ipaddress sh /runme.sh
  #ssh $_username@$_ipaddress /bin/rm /runme.sh
fi

# Reboot target server.
if [ "$_reboot" = "Y" ]; then
  ssh $_username@$_ipaddress reboot
fi

