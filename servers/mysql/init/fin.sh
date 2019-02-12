#!/bin/bash
# MySQL for ubuntu not finished...

source /usr/local/bin/release.include
echo $_RELEASE
mkdir -p $_MYSQL_BACKUP_PATH
mkdir -p $_MYSQL_DATA_PATH  
if [[ $_MYSQL_USE_NFS = 1 ]]; then
    /bin/cp -p /etc/fstab /etc/fstab.bak
    sed '/nfs4/d' /etc/fstab
    echo "$_MYSQL_FSTAB" >> /etc/fstab
    if ! umount -af -t nfs4 ;then
  	echo 
  	echo "Failed to 'umount -af -t nfs4'. EXIT!"
    else
       mount  -a -t nfs4
   fi
fi

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

################ replication ################
# https://dev.mysql.com/doc/refman/5.6/en/replication.html
# # master
# mysql> create user 'repl'@'192.168.1.2' identified by 'pass4repl';
# mysql> grant replication slave on *.* to 'repl'@'192.168.1.2';
# mysql> FLUSH TABLES WITH READ LOCK;
# mysql> SHOW MASTER STATUS;
# $ mysqldump ...
# mysql> UNLOCK TABLES;
# 
# 
# # slave
# mysql> CHANGE MASTER TO
#        MASTER_HOST='192.168.1.1',
#        MASTER_USER='repl',
#        MASTER_PASSWORD='pass4repl',
#        MASTER_LOG_FILE='mysql-binary-log.000001',
#        MASTER_LOG_POS=106;
# mysql> START SLAVE; 
# 
# # check
# mysql> SHOW MASTER STATUS;
# mysql> SHOW SLAVE STATUS \G
# mysql> STOP SLAVE IO_THREAD;
# mysql> START SLAVE;
# 
################ replication ################



