#!/bin/bash
# https://github.com/Panblack/ezdpl

# Check arameters
#echo $1
#echo $2
#echo $3
#echo 
if [ -n "$1" ]; then 
  _silent=$1
  if [ "$_silent" != "Y" ]; then
    if [ "$_silent" != "N" ]; then
      echo "The first parameter must be Y or N. Exit!"
      exit 1
    fi
  fi
else
  echo "silent. Usage: ./ezdpl.sh <Silent Mode Y|N> <ip address>:[port] <app/version> [reboot Y|N(N)] [username(root)]"
  exit 1
fi

if [ -n "$2" ]; then
  #Detailed param check will be needed.
  _ipaddress=$(echo $2|awk -F':' '{print $1}')
  _port=$(echo $2|awk -F':' '{print $2}')
  if [ ${#_port} -eq 0 ]; then
    _port="22"
  fi
else
  echo "ipaddress:port. Usage: ./ezdpl.sh <Silent Mode Y|N> <ip address>:[port] <app/version> [reboot Y|N(N)] [username(root)]"
  exit 1
fi

if [ -n "$3" ]; then
  _app_version=$3
else
  echo "app/version. Usage: ./ezdpl.sh <Silent Mode Y|N> <ip address>:[port] <app/version> [reboot Y|N(N)] [username(root)]"
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
  echo 
  echo "Will initialize a new server, or deploy apps to a certain server, or upgrade a production server."
  echo "Usage: ./ezdpl.sh <Silent Mode Y|N> <ip address>:[port] <app/version> [reboot Y|N(N)] [username(root)]"
  echo "Manually Initialize 10.1.1.1: 		./ezdpl.sh N 10.1.1.1 common/current Y"
  echo "Silently Deploy app_a to 10.1.1.1: 	./ezdpl.sh Y 10.1.1.1:22 app_a/current Y root"
  echo "Silently Upgrade 10.1.1.2's app_a:	./ezdpl.sh Y 10.1.1.2:2222 app_a/20150720"
  echo "Manually Upgrade 10.1.1.2's conf:	./ezdpl.sh N 10.1.1.2:2222 app_a/2015-10-12"
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
echo "Target Server: ${_ipaddress}:${_port}..." 
ssh -p $_port $_username@$_ipaddress uname > /dev/null
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
if [ -f "./apps/$_app_version/prepare.sh" ]; then
  scp -P $_port ./apps/$_app_version/prepare.sh $_username@$_ipaddress:/tmp/
  ssh -p $_port $_username@$_ipaddress sh /tmp/prepare.sh
  echo "$_username@$_ipaddress:/tmp/prepare.sh executed."
fi

# Start copy app/version/files/*
if [ -d ./apps/$_app_version/files  ]; then 
  scp -P $_port -r ./apps/$_app_version/files/* $_username@$_ipaddress:/
  echo "./apps/$_app_version/files/* copied."
fi

# Run finish.sh on the target server
if [ -f "./apps/$_app_version/finish.sh" ]; then
  scp -P $_port ./apps/$_app_version/finish.sh $_username@$_ipaddress:/tmp/
  ssh -p $_port $_username@$_ipaddress sh /tmp/finish.sh
  echo "$_username@$_ipaddress:/tmp/finish.sh executed."
fi

# Reboot target server.
if [ "$_reboot" = "Y" ]; then
  echo
  echo "Target server will reboot..."
  echo
  ssh -p $_port $_username@$_ipaddress reboot
fi
echo "Target Server: ${_ipaddress}:${_port} done!"; echo
# End of ezdpl.sh
