#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# release nfs4 mounts
for x in `mount -t nfs4|awk '{print $3}'`; do 
    fuser -km $x
done

if ! umount -af -t nfs4 ;then
  echo 
  echo "Failed to 'umount -af -t nfs4'. EXIT!"
  echo 
  exit 1
fi

_backup_dir="/opt/backup_`date +%Y%m%d_%H%M%S`"
cd /opt/ && mv -f jdk* logs* libs* app* webs* html* wars* $_backup_dir
cd /data && mv -f webShare* $_backup_dir

mkdir -p $_NFS_DIRS_INIT
mkdir -p $_LOCAL_DIRS_FOR_NFS

killall -9 yum
yum clean all
yum -y install nfs-utils
yum -y update  nfs-utils

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
