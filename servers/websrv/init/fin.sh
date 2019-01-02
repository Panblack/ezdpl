#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

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
/bin/mv /etc/nginx/nginx.conf          $_backup_dir
/bin/mv /etc/nginx/conf.d/default.conf $_backup_dir
/bin/cp /tmp/nginx/*   		       /etc/nginx/
chkconfig nginx on
nginx -t && service nginx start

# Install rpms
cd /opt/packages
yum localinstall *.rpm

echo "`date +%F_%T` websrv/init " >> /tmp/ezdpl.log

