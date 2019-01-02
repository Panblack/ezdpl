#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# Get dirs ready
mkdir -p /opt/html
mkdir -p /data/webShare/read
mkdir -p /data/webShare/write

# Get nginx ready
case $_RELEASE in
    CENTOS6)
        sed -i 's/X/6/g' /etc/yum.repos.d/nginx.repo
        ;;
    CENTOS7)
        sed -i 's/X/7/g' /etc/yum.repos.d/nginx.repo
        ;;
esac

yum clean all
yum install nginx python-pip -y

mkdir -p /etc/nginx/backup
/bin/cp /etc/nginx/nginx.conf          /etc/nginx/backup/nginx.conf.bak.`date +%Y%m%d_%H%M%S`
/bin/cp /etc/nginx/conf.d/default.conf /etc/nginx/backup/default.conf.bak.`date +%Y%m%d_%H%M%S`

chkconfig nginx on
service start nginx

pip install --upgrade pip
pip install ngxtop

# Install rpms
cd /opt/packages
yum localinstall *.rpm

echo "`date +%F_%T` websrv/init " >> /tmp/ezdpl.log
