#!/bin/bash
source /usr/local/bin/release.include
source /usr/local/bin/japp.include
echo "RELEASE:    $_RELEASE"
echo "_JDK_TYPE:  $_JDK_TYPE"
echo
echo "japp.include:"
echo "_HOME_DIR:  $_HOME_DIR"
echo "_BASES_DIR: $_BASES_DIR"
echo "_APP_PATH:  $_APP_PATH"
echo "_LOG_PATH:  $_LOG_PATH"
echo "_LIB_PATH:  $_LIB_PATH"
echo "_OPER_PATH: $_OPER_PATH"
echo 

# Get dirs ready
# kill java app processes if present
killall -9 java

_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir

if [[ -n $_HOME_DIR ]]; then
    echo "_HOME_DIR is deprecated...."
    /bin/mv -f $_HOME_DIR $_backup_dir
    mkdir -p $_HOME_DIR
fi

/bin/mv -f $_OPER_PATH $_BASES_DIR $_APP_PATH $_LOG_PATH $_LIB_PATH $_backup_dir
mkdir -p $_BASES_DIR $_APP_PATH $_LOG_PATH $_LIB_PATH
mkdir -p $_OPER_PATH $_OPER_PATH/cook $_OPER_PATH/build $_OPER_PATH/todeploy $_OPER_PATH/_config $_OPER_PATH/archive $_OPER_PATH/backup

if [[ $_JDK_TYPE = oracle ]]; then
    echo "$_zz_jdk_oracle" > /etc/profile.d/zz_jdk.sh
    source /etc/profile.d/zz_jdk.sh
    # jdk and symbolic link
    cd /opt
    echo "Extracts jdk"
    for j in /opt/packages/jdk*.tar.gz ; do
        tar zxf $j
    done
    # Make the latest version default
    _jdk=`find -type d -name "jdk1.*"|sort -V|tail -1`
    echo "$_jdk is default jdk"
    ln -sf $_jdk $JAVA_HOME

    # Maven
    cd /opt
    echo "Extracts maven"
    for m in /opt/packages/apache-maven*.tar.gz ; do
        tar zxf $m
    done
    # Make the latest version default
    _maven=`find -type d -name apache-maven*|sort -V|tail -1`
    echo "$_maven is default maven"
    ln -sf $_maven $MAVEN_HOME

elif [[ $_JDK_TYPE = open ]]; then
    echo "$_zz_jdk_open" > /etc/profile.d/zz_jdk.sh
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel maven

else
    echo "Set _JDK_TYPE=oracle or _JDK_TYPE=open in release.include!"; exit 1

fi


# Configure tomcats webs
# Configure tomcats app/webs
cd $_BASES_DIR
pwd
echo "Extracts tomcat*.tar.gz"
for ttar in /opt/packages/apache-tomcat-*.tar.gz ; do
    tar zxf $ttar
done

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

    _webdir="app-`echo $tm|sed 's/apache-tomcat-//g'`"
    cd ..
    mv -f $tm $_webdir
done

# Install rpms
cd /opt/packages
yum localinstall *.rpm 2>/dev/null

echo "make working dirs owned by $_WORK_USER:$_WORK_USER "
chown -R $_WORK_USER:$_WORK_USER $_BASES_DIR
chown -R $_WORK_USER:$_WORK_USER $_APP_PATH
chown -R $_WORK_USER:$_WORK_USER $_LOG_PATH
chown -R $_WORK_USER:$_WORK_USER $_LIB_PATH
chown -R $_WORK_USER:$_WORK_USER $_OPER_PATH

echo "`date +%F_%T` websrv/javasrv " >> /tmp/ezdpl.log
                                                              
#End

