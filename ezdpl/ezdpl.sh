#!/bin/bash
# https://github.com/Panblack/ezdpl

# Check arameters
if [ -n "$1" ]; then 
  _silent=$1
else
  echo "Usage: ./ezdpl.sh [Silent Mode Y|N(N)] <ip address> <app/version> [reboot Y|N(N)] [username(root)]...exit!"
  exit 1
fi

if [ -n "$2" ]; then
  _ipaddress=$2
else
  echo "Usage: ./ezdpl.sh [Silent Mode Y|N(N)] <ip address> <app/version> [reboot Y|N(N)] [username(root)]...exit!"
  exit 1
fi

if [ -n "$3" ]; then
  _app_version=$3
else
  echo "Usage: ./ezdpl.sh [Silent Mode Y|N(N)] <ip address> <app/version> [reboot Y|N(N)] [username(root)]...exit!"
  exit 1
fi

# Optional parameters
if [ -n "$4" ]; then
  _reboot=$4
else 
  _reboot="N"
fi
if [ -n "$5" ]; then
  _username=$5
else
  _username="root"
fi

# Silent mode or not
if [ "$_silent" != "Y" ]; then
  echo
  echo "Ezdpl does things in a raw and simple way."
  echo "https://github.com/Panblack/ezdpl"
  echo "Warning: This version works only on RHEL/CentOS."
  echo 
  echo "Will initialize a new server."
  echo "Or deploy apps to a certain server."
  echo "Or upgrade a running production server."
  echo "Usage: ./ezdpl.sh [Silent Mode Y|N(N)] <ip address> <app/version> [reboot Y|N(N)] [username(root)]"
  echo "Manually Initialize 10.1.1.1: 		./ezdpl.sh N 10.1.1.1 common/current Y"
  echo "Silently Deploy app_a to 10.1.1.1: 	./ezdpl.sh Y 10.1.1.1 app_a/current Y root"
  echo "Silently Upgrade 10.1.1.2's app_a:	./ezdpl.sh Y 10.1.1.2 app_a/20150720"
  echo "Manually Upgrade 10.1.1.2's conf:	./ezdpl.sh N 10.1.1.2 app_a/2015-10-12"
  echo

  # Confirmation
  read -p "Will overwrite configuration files or apps on $_ipaddress. Enter Y to continue: "
  if [ "$REPLY" != "Y" ]; then
    echo "Exit"
    exit 0
  fi

  # Confirmation again
  read -p "Are you sure? Enter Y to continue: " 
  if [ "$REPLY" != "Y" ]; then
    echo "Exit"
    exit 0 
  fi
fi

# Check
ssh $_username@$_ipaddress uname > /dev/null
if [ "$?" != "0" ]; then
  echo
  echo "$_ipaddress is not reachable. "
  exit 1
fi

if [ ! -d "./apps/$_app_version" ]; then
  echo
  echo "There is no $_app_version configured here !"
  exit 1
fi

# Everything seems OK. Go!
# Run prepare.sh on the target server
echo "Target Server: $_ipaddress..." 
if [ -f "./apps/$_app_version/prepare.sh" ]; then
  scp ./apps/$_app_version/prepare.sh $_username@$_ipaddress:/tmp/
  ssh $_username@$_ipaddress sh /tmp/prepare.sh
  echo "$_username@$_ipaddress:/tmp/prepare.sh executed."
  #ssh $_username@$_ipaddress /bin/rm /tmp/prepare.sh
  #echo "$_username@$_ipaddress:/tmp/prepare.sh deleted."
fi

# Start copy app/version/files/*
if [ -d ./apps/$_app_version/files  ]; then 
  scp -r ./apps/$_app_version/files/* $_username@$_ipaddress:/
  echo "./apps/$_app_version/files/* copied."
fi

# Run finish.sh on the target server
if [ -f "./apps/$_app_version/finish.sh" ]; then
  scp ./apps/$_app_version/finish.sh $_username@$_ipaddress:/tmp/
  ssh $_username@$_ipaddress sh /tmp/finish.sh
  echo "$_username@$_ipaddress:/tmp/finish.sh executed."
  #ssh $_username@$_ipaddress /bin/rm /tmp/finish.sh
  #echo "$_username@$_ipaddress:/tmp/finish.sh deleted."
fi

# Reboot target server.
if [ "$_reboot" = "Y" ]; then
  echo
  echo "Target server will reboot..."
  echo
  ssh $_username@$_ipaddress reboot
fi
# End of ezdpl.sh
