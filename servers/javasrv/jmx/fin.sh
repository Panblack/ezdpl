#!/bin/bash

cd /opt/webs
_ip=` ip a show eth0|grep -v inet6 |grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
_port1=10001
_port2=20001
for x in * ; do 
    # Add <Listener> element to <Server> ( sed is not perfect, consider replace it with xmlstarlet) 
    sed -i /"org.apache.catalina.mbeans.JmxRemoteLifecycleListener"/d $x/conf/server.xml
    sed -i /'Server port=".*" shutdown="SHUTDOWN"'/a\ "<Listener className='org.apache.catalina.mbeans.JmxRemoteLifecycleListener' rmiBindAddress='$_ip' useLocalPorts='false' rmiRegistryPortPlatform='$_port1' rmiServerPortPlatform='$_port2' />" $x/conf/server.xml
    dos2unix $x/conf/server.xml

    echo -e "reader readerPassword\nwriter writerPassword" > $x/conf/jmxremote.password
    echo -e "reader readonly\nwriter readwrite"  > $x/conf/jmxremote.access

    iptables-iport a "$_port1 $_port2"

    _port1=$(( _port1 + 1 ))
    _port2=$(( _port2 + 1 ))
done

sed -i /'jmxremote'/d /opt/app/tomcat/bin/setenv.sh
_setenv_append='
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.password.file=./conf/jmxremote.password
-Dcom.sun.management.jmxremote.access.file=./conf/jmxremote.access  
-Dcom.sun.management.jmxremote.ssl=false"
'
cd /opt/app/
for t in *; do 
   echo "$_setenv_append" >> /opt/app/${t}/bin/setenv.sh
done
