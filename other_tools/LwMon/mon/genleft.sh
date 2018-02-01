#!/bin/bash

appdir=$(dirname $(readlink -f "$0"))
lwmon="/dev/shm/lwmon"

for x in $(cat ${appdir}/server.list)
do
        server=($(echo $x|awk -F',' '{print $1,$2}'))
        ip=${server[0]}
        echo "<a href="$ip.html" target="mainFrame">[$ip]</a><br>" >> /dev/shm/htmllist.txt
done
        cp -f ${appdir}/template-left.html ${lwmon}/left.html
        sed '/{LIST}/r /dev/shm/htmllist.txt' ${lwmon}/left.html -i
        sed 's/{LIST}//g' ${lwmon}/left.html -i 
        rm -rf /dev/shm/htmllist.txt

