#!/bin/bash

killall -9 java

if ! umount -af -t nfs4 ;then
  echo 
  echo "Failed to 'umount -af -t nfs4'. EXIT!"
  echo 
  exit 1
fi

cd /opt/ && rm jdk* logs* libs*  -rf 
cd /opt/ && rm app/* webs/* -rf 

killall -9 yum
yum clean all
yum -y install nfs-utils bash openssh openssl openssl-devel 
systemctl disable nfs.service
systemctl disable nfslock.service
systemctl disable rpcbind.service
systemctl disable rpcgssd.service
systemctl disable rpcidmapd.service
systemctl disable rpcsvcgssd.service
systemctl stop  nfs.service
systemctl stop  nfslock.service
systemctl stop  rpcbind.service
systemctl stop  rpcgssd.service
systemctl stop  rpcidmapd.service
systemctl stop  rpcsvcgssd.service

echo 
echo "nfs-utils (client) configured."
echo
