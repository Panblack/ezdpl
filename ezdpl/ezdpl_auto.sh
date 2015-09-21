#!/bin/bash
# ezdpl.sh in silent mode
#
# "ezdpl does things in a raw and simple way."
# "https://github.com/Panblack/ezdpl"
# 
# "Will initialize a new target server."
# "Or deploy an app to the target server."
# "Or upgrade a running production server."
# "Usage: ./ezdpl.sh <ip address> <app/version> [reboot Y/N(N)] [username(root)]"
# "Init 10.1.1.1: 		./ezdpl.sh 10.1.1.1 common/current"
# "Deploy uf to 10.1.1.1: 	./ezdpl.sh 10.1.1.1 uf/current Y root"
# "Upgrade 10.1.1.2's app:	./ezdpl.sh 10.1.1.2 ea/20150720 N"
# "Upgrade 10.1.1.2's conf:	./ezdpl.sh 10.1.1.2 ea/ea2 N"
#
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

# Run prepare.sh on the target server
if [ -f "./apps/$_app_version/prepare.sh" ]; then
  scp ./apps/$_app_version/prepare.sh $_username@$_ipaddress:~/
  ssh $_username@$_ipaddress sh ~/prepare.sh
  echo "$_username@$_ipaddress:~/prepare.sh executed."
  #ssh $_username@$_ipaddress /bin/rm ~/prepare.sh
  #echo "$_username@$_ipaddress:~/prepare.sh deleted."
fi

# Start copy app/version/files/*
if [ -d ./apps/$_app_version/files  ]; then
  scp -r ./apps/$_app_version/files/* $_username@$_ipaddress:/
  echo "./apps/$_app_version/files/* copied."
fi
# Run finish.sh on the target server
if [ -f "./apps/$_app_version/finish.sh" ]; then
  scp ./apps/$_app_version/finish.sh $_username@$_ipaddress:~/
  ssh $_username@$_ipaddress sh ~/finish.sh
  echo "$_username@$_ipaddress:~/finish.sh executed."
  #ssh $_username@$_ipaddress /bin/rm ~/finish.sh
  #echo "$_username@$_ipaddress:~/finish.sh deleted."
fi

# Reboot target server.
if [ "$_reboot" = "Y" ]; then
  ssh $_username@$_ipaddress reboot
fi
