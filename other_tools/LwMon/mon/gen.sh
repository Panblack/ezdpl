#!/bin/bash 
 
appdir=$(dirname $(readlink -f "$0"))
lwmon="/dev/shm/lwmon"

if [ ! -d $lwmon ] ; then
    mkdir -p ${lwmon}
else
    /bin/rm ${lwmon} -rf
    mkdir -p ${lwmon}
fi

cp ${appdir}/template-index.html ${lwmon}/index.html
cp ${appdir}/template-warning.html ${lwmon}/warning.html
cp -r ${appdir}/common/ ${lwmon}/
/bin/sh ${appdir}/genleft.sh
chown -R apache:apache /dev/shm/lwmon 2>/dev/null

checkselinux=$(getenforce 2>/dev/null)
if [ "$checkselinux" != "Disabled" ] ; then 
   chcon -R -t httpd_sys_content_t /dev/shm/lwmon
fi


