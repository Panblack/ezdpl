#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

if [[ $_USE_NFS = 0 ]]; then
    exit 
fi

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

_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir
cd /opt  && /bin/mv -f html* $_backup_dir
cd /data && /bin/mv -f webShare* $_backup_dir

#_LOCAL_DIRS_FOR_NFS="/data/logs/nginx /data/webShare/read /data/webShare/write"
#_NFS_DIRS_INIT="/data/webShare/read/html /data/webShare/read/webapps /data/webShare/read/download /data/webShare/read/config "
#
mkdir -p $_LOCAL_DIRS_FOR_NFS

/bin/cp /etc/fstab $_backup_dir
echo "$_WEBSRV_FSTAB" >> /etc/fstab
mount -a -t nfs4

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
        systemctl disable rpc-gssd.service
        systemctl disable rpc-rquotad.service     
        systemctl disable rpc-statd-notify.service
        systemctl disable rpc-statd.service       
	systemctl stop nfs.service
	systemctl stop nfslock.service
	systemctl stop rpcbind.service
	systemctl stop rpcgssd.service
	systemctl stop rpcidmapd.service
	systemctl stop rpcsvcgssd.service
        systemctl stop rpc-gssd.service          
        systemctl stop rpc-rquotad.service
        systemctl stop rpc-statd-notify.service
        systemctl stop rpc-statd.service
	;;
    UBUNTU)
	;;
esac

echo 
echo "nfs-utils (client) configured."
echo
