#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# Get dirs ready
mkdir -p /opt/logs /opt/app /opt/webs
mkdir -p /opt/wars/cook /opt/wars/build /opt/wars/todeploy /opt/wars/_config /opt/wars/archive /opt/wars/backup

# jdk and symbolic link
cd /opt
echo "Extracts jdk"
for j in /opt/packages/jdk*.tar.gz ; do
    tar zxf $j 
done
# Make the latest version default
_jdk=`find -type d -name "jdk1.*"|sort -V|tail -1`
echo "$_jdk is default jdk"
ln -sf $_jdk ./jdk

# Maven
cd /opt
echo "Extracts maven"
for m in /opt/packages/apache-maven*.tar.gz ; do
    tar zxf $m
done
# Make the latest version default
_maven=`find -type d -name apache-maven*|sort -V|tail -1`
echo "$_maven is default maven"
ln -sf $_maven ./maven

# Configure tomcats app/webs
cd /opt/app
echo "Extracts tomcat*.zip"
for tzip in /opt/packages/apache-tomcat-*.zip ; do
    unzip -q $tzip
done
echo "Extracts tomcat*.tar.gz"
for ttar in /opt/packages/apache-tomcat-*.tar.gz ; do
    tar zxf $ttar
done

_setenv='
JAVA_OPTS="-server -Xms1024m -Xmx1024m -XX:+UseG1GC"
CATALINA_OPTS=" -Djava.security.egd=/dev/urandom"
UMASK="0022"
CATALINA_OUT=/dev/null'

for tm in apache-tomcat-*/ ; do 
    cd $tm
    pwd
    rm ./bin/*.bat -f
    chmod +x ./bin/*.sh
    echo "$_setenv" > ./bin/setenv.sh
    rm ./webapps/* -rf
    rm ./work/*    -rf
    rm ./temp/*    -rf
    
    # context
    sed -i '/<Context>/a\    <Resources allowLinking="true" cachingAllowed="true" cacheMaxSize="102400" \/>' ./conf/context.xml

    # accesslog
    # pattern="%h %l %u %t &quot;%r&quot; %s %b %D %S %{X-Forwarded-For}i %{Referer}i" />
    # %h - Remote host name, %l - Remote logical username, %u - Remote user that was authenticated, %t - Date and time
    # %r - First line of the request (method and request URI), %s - HTTP status code, %b - Bytes sent 
    # %D - Time taken to process the request, in millis 
    # %S - User session ID
    sed -i 's/%s %b/%s %b %D %S %{X-Forwarded-For}i %{Referer}i/g' ./conf/server.xml

    # http protocol 
    sed -i 's/protocol="HTTP\/1.1"/protocol=\"org.apache.coyote.http11.Http11Nio2Protocol\"/g' ./conf/server.xml

    # tomcat optimization
    sed -i '/maxThreads=.* minSpareThreads=.* acceptCount=.* enableLookups=/d' ./conf/server.xml
    sed -i '/Connector port=\".*\" protocol=\"org.apache.coyote.http11.Http11Nio2Protocol\"/a\               maxThreads=\"640\" minSpareThreads=\"128\" acceptCount=\"768\" enableLookups=\"false\" ' ./conf/server.xml

    _webdir="/opt/webs/app-`echo $tm|sed 's/apache-tomcat-//g'`"
    mkdir -p $_webdir
    /bin/cp -r ./* $_webdir
    cd ..
done

# Make the latest version default
_tomcat=`find -type d -name "apache-tomcat-*"|sort -V|tail -1`
ln -sf $_tomcat ./tomcat

# Install rpms
cd /opt/packages
yum localinstall *.rpm

echo "`date +%F_%T` websrv/javasrv " >> /tmp/ezdpl.log
