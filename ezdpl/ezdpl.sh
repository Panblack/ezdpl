#!/bin/bash
echo
echo "ezdpl does things in a raw and simple way."
echo "https://github.com/Panblack/ezdpl"
echo 
echo "Will initialize a new target server."
echo "Or deploy an app to the target server."
echo "Or upgrade a running production server."
echo "Usage: ./ezdpl.sh <ip address> <app/version> [reboot Y/N(N)] [username(root)]"
echo "Init 10.1.1.1: 		./ezdpl.sh 10.1.1.1 common/current"
echo "Deploy web_a to 10.1.1.1: ./ezdpl.sh 10.1.1.1 web_a/current Y root"
echo "Upgrade 10.1.1.2's app:	./ezdpl.sh 10.1.1.2 java_c/20150720 N"
echo "Upgrade 10.1.1.2's conf:	./ezdpl.sh 10.1.1.2 java_c/java_c2 N"
echo

# Confirmation
read -p "Will overwrite configuration files or app on $1. Enter Y to continue: "
if [ "$REPLY" != "Y" ]; then
  echo "Exit"
  exit 0
fi
read -p "Are you sure? Enter Y to continue: " 
if [ "$REPLY" != "Y" ]; then
  echo "Exit"
  exit 0
fi

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
echo "./apps/$_app_version/* copied."

# Run runme.sh on the target server
if [ -f "./apps/$_app_version/runme.sh" ]; then
  ssh $_username@$_ipaddress sh /runme.sh
  echo "$_username@$_ipaddress:/runme.sh executed."
  #ssh $_username@$_ipaddress /bin/rm /runme.sh
  #echo "$_username@$_ipaddress:/runme.sh deleted."
fi

# Reboot target server.
if [ "$_reboot" = "Y" ]; then
  echo
  echo "Target server will reboot..."
  echo
  ssh $_username@$_ipaddress reboot
fi

