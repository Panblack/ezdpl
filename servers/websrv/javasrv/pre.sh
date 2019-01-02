#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

#  umount nfs
if ! umount -af -t nfs4 ;then
  echo 
  echo "Failed to 'umount -af -t nfs4'. EXIT!"
  echo 
  exit 1
fi

cd /opt/ && rm jdk* logs* libs*  -rf 
cd /opt/ && rm app/* webs/* -rf 

killall -9 java
killall -9 yum
yum clean all
yum -y install nfs-utils gcc bash openssh openssl openssl-devel 

case $_RELEASE in
    CENTOS6)
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
	;;
    CENTOS7)
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
	;;
    UBUNTU)
	;;
esac

echo 
echo "nfs-utils (client) configured."
echo
