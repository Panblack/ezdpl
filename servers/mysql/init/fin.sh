#!/bin/bash
if grep " 6." /etc/redhat-release ; then
    rpm -ivh https://repo.mysql.com//mysql57-community-release-el6-10.noarch.rpm
fi
if grep " 7." /etc/redhat-release ; then
    rpm -ivh https://repo.mysql.com//mysql57-community-release-el7-10.noarch.rpm
fi
mkdir -p /data/mysql
mkdir -p /data/backup

yum-config-manager --disablerepo mysql57-community
yum-config-manager --enablerepo  mysql56-community
yum install -y mysql-community-server
mv /etc/my.cnf files/etc/my.cnf.org
mv /etc/my.cnf.new /etc/my.cnf
systemctl enable mysqld.service
systemctl start mysqld.service
mql_secure_installation
