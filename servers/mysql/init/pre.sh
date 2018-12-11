#!/bin/bash

if rpm -qa|egrep 'mysql|mariadb' ; then
    yum erase -y mysql*
    yum erase -y mariadb*
fi

if dpkg --list|egrep 'mysql|mariadb' ;then
    sudo apt-get remove mysql*
    sudo apt-get remove mariadb*
fi

