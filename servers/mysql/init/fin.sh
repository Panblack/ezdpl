#!/bin/bash
# MySQL for ubuntu not finished...

source /usr/local/bin/release.include
echo $_RELEASE
mkdir -p /data/mysql
mkdir -p /data/mysqlbackup

case $_RELEASE in
    CENTOS6|CENTOS7)
	rpmkeys --import https://repo.mysql.com/RPM-GPG-KEY-mysql
	if [[ $_RELEASE = CENTOS6 ]]; then
    	    rpm -ivh https://repo.mysql.com/mysql57-community-release-el6.rpm
        elif [[ $_RELEASE = CENTOS7 ]]; then
    	    rpm -ivh https://repo.mysql.com/mysql57-community-release-el7.rpm
	fi

	for x in `ps aux|grep -i 'yum' |grep -v grep|awk '{print $2}'`; do 
    		kill $x || kill -9 $x
	done
	yum clean all
	yum install -y yum-utils
	yum-config-manager --quiet --disable mysql57-community > /dev/null
	yum-config-manager --quiet --disable mysql80-community > /dev/null
	yum-config-manager --quiet --enable  mysql56-community > /dev/null
	grep "enabled=1" -B2 /etc/yum.repos.d/mysql-community.repo
	echo;echo 
	echo "Installing mysql-community-server..."
	yum install -y mysql-community-server
	mv /etc/my.cnf /etc/my.cnf.org
	mv /etc/my.cnf.new /etc/my.cnf
	chkconfig mysqld on
	service mysqld start
	echo;echo
	echo "Login remote server and run:"
       	echo "mysql_secure_installation"
	echo "mysql_config_editor set --host=localhost --user=root --password"
	;;
    UBUNTU)
	sudo dpkg -i https://repo.mysql.com/mysql-apt-config_0.8.7-1_all.deb
	if [[ -f /etc/apt/sources.list.d/mysql.list ]]; then
	    echo ""
	fi
	;;
esac
