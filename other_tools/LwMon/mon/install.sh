#!/bin/bash

appdir=$(dirname $(readlink -f "$0"))

#Create httpd virtual dir
checkhttpd=$(grep -i "Require all granted" /etc/httpd/conf/httpd.conf |wc -l)
if [ "$checkhttpd" = 0 ]  ; then
 webalias='
 Alias /lwmon "/dev/shm/lwmon/"
 <Directory /dev/shm/lwmon/>
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
 </Directory>
 '
else
 #For httpd 2.4.x and above
 webalias='
 Alias /lwmon "/dev/shm/lwmon/"
 <Directory /dev/shm/lwmon/>
    Options FollowSymLinks
    AllowOverride None
    # Allow open access:
    Require all granted
 </Directory>
 '
fi
echo "$webalias" > /etc/httpd/conf.d/lwmon.conf
service httpd reload
echo "httpd virtual dir created."

#Create initial webpages
/bin/sh ${appdir}/gen.sh
echo "Initial webpages created in /dev/shm/lwmon."

#Make gen.sh run at system boot
checkrc=$(grep "${appdir}/gen.sh" /etc/rc.local | wc -l)
if [ "$checkrc" = "0" ] ; then
    echo "${appdir}/gen.sh" >> /etc/rc.local
fi
echo "Initial webpages will be recreated at system boot."

#Create a cron job for genpages.sh
checkcron=$(grep "genpages.sh" /var/spool/cron/root  2>/dev/null| wc -l)
if [ "$checkcron" != "0" ] ; then
    sed -i '/genpages.sh/d' /var/spool/cron/root
fi
echo "*/5 * * * * ${appdir}/genpages.sh" >> /var/spool/cron/root
echo "cron job for genpages.sh created!"

echo "Run this script again if you need to reinitialize LwMon."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "Run the following command to verify:"
echo "crontab -e"
echo "cat /etc/rc.local"
echo "cat /etc/httpd/conf.d/lwmon.conf"
echo 
echo "Now take your time to edit your own 'server.list' and make sure you can log into the servers as root without password."
echo "Then visit http://IpAddressOfThisServer/lwmon to enjoy."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo


