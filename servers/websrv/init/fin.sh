#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# kill web app processes if present
killall -9 node 2>/dev/null

# prepare html dir
_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir
cd /opt  && /bin/mv -f html $_backup_dir
if [[ -z $_LOCAL_DIRS_FOR_HTML ]]; then
  echo "_LOCAL_DIRS_FOR_HTML not configured in release.include. use default '/opt/html' "
  _LOCAL_DIRS_FOR_HTML="/opt/html"
fi
mkdir -p $_LOCAL_DIRS_FOR_HTML
chown -R root:root $_LOCAL_DIRS_FOR_HTML
chmod 755 $_LOCAL_DIRS_FOR_HTML
echo "$_LOCAL_DIRS_FOR_HTML created."
echo

# prepare for nfs shares
if [[ $_USE_NFS = 0 ]]; then
    exit 0
fi

# install nfs-utils
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
	systemctl disable nfs-mountd.service
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
	systemctl stop nfs-mountd.service
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
echo "nfs-utils (client) installed."
echo

# release nfs4 mounts if present
for x in `mount -t nfs4|awk '{print $3}'`; do
    fuser -km $x
done

if ! umount -af -t nfs4 ;then
  echo
  echo "Failed to 'umount -af -t nfs4'. EXIT!"
  echo
  exit 1
fi

# backup /data/webShare if present
if [[ -d /data/webShare ]]; then
  cd /data && /bin/mv -f webShare* $_backup_dir
fi

mkdir -p $_LOCAL_DIRS_FOR_NFS

# configure nfs share
if [[ -n $_WEBSRV_FSTAB ]]; then
  /bin/cp -p /etc/fstab $_backup_dir
  sed -i '/nfs4/d' /etc/fstab
  echo "$_WEBSRV_FSTAB" >> /etc/fstab
  if mount -a -t nfs4; then
    echo "nfs4 mounts ok"
    echo
  else
    echo "Failed to 'mount -a -t nfs4'. EXIT!"
    echo
    exit 1
  fi
fi


# Get nginx ready
case $_RELEASE in
    CENTOS6)
        sed -i 's/X/6/g' /etc/yum.repos.d/nginx.repo
        ;;
    CENTOS7)
        sed -i 's/X/7/g' /etc/yum.repos.d/nginx.repo
        ;;
esac

# Install nginx & ngxtop 
yum clean all
yum install nginx python-pip -y
pip install --upgrade pip
pip install ngxtop

# Replace nginx confs
_backup_dir="/etc/nginx/backup/`date +%F_%H%M%S`"
mkdir -p $_backup_dir
/bin/mv /etc/nginx/nginx.conf $_backup_dir
/bin/mv /etc/nginx/conf.d/*   $_backup_dir
/bin/cp -r /tmp/nginx/*       /etc/nginx/

if [[ -z $_LOCAL_DIRS_FOR_HTML ]]; then
  echo "_LOCAL_DIRS_FOR_HTML not configured in release.include. use default '/opt/html' "
  _LOCAL_DIRS_FOR_HTML="/opt/html"
fi
mkdir -p ${_LOCAL_DIRS_FOR_HTML}/example
echo example > ${_LOCAL_DIRS_FOR_HTML}/example/index.html
mkdir -p ${_LOCAL_DIRS_FOR_HTML}/whichami
hostname -s > ${_LOCAL_DIRS_FOR_HTML}/whichami/index.html

# /etc/hosts 
sed -i '/www.example.com/d'             /etc/hosts
echo '127.0.0.1     www.example.com' >> /etc/hosts 

chkconfig nginx on
nginx -t && service nginx start

# Install rpms
cd /opt/packages
yum localinstall *.rpm 2>/dev/null

echo "`date +%F_%T` websrv/init " >> /tmp/ezdpl.log

