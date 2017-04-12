#!/bin/bash
if rpm -qa|grep 'mysql' ; then
    yum erase -y mysql*
fi

