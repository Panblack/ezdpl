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

_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir
cd /opt  && /bin/mv -f app* webs* javaapp* logs* wars* jdk* libs* $_backup_dir

#_LOCAL_DIRS_FOR_APPS="/opt/html /opt/app /opt/webs /opt/javaapp /opt/logs /opt/libs"
#_LOCAL_DIRS_FOR_DEPLOY="/opt/wars/build /opt/wars/todeploy /opt/wars/cook /opt/wars/archive /opt/wars/_config"
#
mkdir -p $_LOCAL_DIRS_FOR_APPS
mkdir -p $_LOCAL_DIRS_FOR_DEPLOY

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
