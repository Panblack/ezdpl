#!/bin/bash

cd /opt/webs
# _ip=`ip a|grep -w inet |grep -v '127.0.0.1'|awk '{print $2}'|awk -F/ '{print $1}'`
_port1=10001
_port2=20001
_reader_user="readerUser"
_writer_user="writerUser"
_reader_password="readerPassword"
_writer_password="writerPassword"
for x in * ; do 
    # Add <Listener> element to <Server> ( sed is not perfect, consider replace it with xmlstarlet) 
    sed -i /"org.apache.catalina.mbeans.JmxRemoteLifecycleListener"/d $x/conf/server.xml
    sed -i /'Server port=".*" shutdown="SHUTDOWN"'/a\ "<Listener className='org.apache.catalina.mbeans.JmxRemoteLifecycleListener' rmiBindAddress='0.0.0.0' useLocalPorts='false' rmiRegistryPortPlatform='$_port1' rmiServerPortPlatform='$_port2' />" $x/conf/server.xml
    dos2unix $x/conf/server.xml

    echo -e "${_reader_user} ${_reader_password}\n${_writer_user} ${_writer_password}" > $x/conf/jmxremote.password
    echo -e "${_reader_user} readonly\n${_writer_user} readwrite"  > $x/conf/jmxremote.access
    chmod o-rwx $x/conf/jmxremote.password
    chmod o-rwx $x/conf/jmxremote.access
    /usr/local/bin/iptables-iport a "$_port1 $_port2"

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
for t in *tomcat*/; do 
    sed -i /"Dcom.sun.management"/d /opt/app/${t}/bin/setenv.sh
    echo "$_setenv_append" >> /opt/app/${t}/bin/setenv.sh
    _version=`${t}/bin/version.sh|grep "Server version"|awk -F/ '{print $2}'`
    _big_version=`echo $_version|awk -F. '{print $1}'`
    _download_url="https://archive.apache.org/dist/tomcat/tomcat-${_big_version}/v${_version}/bin/extras/catalina-jmx-remote.jar"
    cd ${t}/lib 
done

cd /opt/jdk/lib
wget "http://repo.typesafe.com/typesafe/maven-releases/cmdline-jmxclient/cmdline-jmxclient/0.10.3/cmdline-jmxclient-0.10.3.jar"

echo "`date +%F_%T` javasrv/jmx " >> /tmp/ezdpl.log
