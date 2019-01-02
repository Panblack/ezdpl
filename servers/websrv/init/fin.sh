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

mkdir -p /opt/html

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

mkdir -p /opt/html/example
echo example >> /opt/html/example/index.html
mkdir -p /opt/html/whichami
hostname -s >> /opt/html/whichami/index.html

# /etc/hosts 
sed -i '/www.example.com/d'             /etc/hosts
echo '127.0.0.1     www.example.com' >> /etc/hosts 

chkconfig nginx on
nginx -t && service nginx start

# Install rpms
cd /opt/packages
yum localinstall *.rpm

echo "`date +%F_%T` websrv/init " >> /tmp/ezdpl.log

