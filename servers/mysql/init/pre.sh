#!/bin/bash

if rpm -qa|grep 'mysql' ; then
    yum erase -y mysql*
fi

if dpkg --list|grep 'mysql' ;then
    sudo apt-get remove mysql*
fi

