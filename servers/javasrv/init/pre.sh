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
chkconfig nfs off
chkconfig nfslock off
chkconfig rpcbind off
chkconfig rpcgssd off
chkconfig rpcidmapd off
chkconfig rpcsvcgssd off
service nfs stop
service nfslock stop
service rpcbind stop
service rpcgssd stop
service rpcidmapd stop 
service rpcsvcgssd stop

echo 
echo "nfs-utils (client) configured."
echo
