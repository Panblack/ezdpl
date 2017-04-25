#!/bin/bash
source /tmp/release.include

# firewalld 
case $_RELEASE in
    CENTOS6)
        # firewall
        # Consider change sshd port to 2222 later.
        chkconfig iptables on
        service iptables start
        iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8009 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8081 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8082 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 8083 -j ACCEPT
        iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
        /etc/init.d/iptables save
        ;;
    CENTOS7)
        # firewall
        systemctl enable firewalld
        systemctl start  firewalld
	firewall-cmd --add-port 80/tcp --permanent
	firewall-cmd --add-port 443/tcp --permanent
	firewall-cmd --add-port 8009/tcp --permanent
	firewall-cmd --add-port 8080/tcp --permanent
	firewall-cmd --add-port 8081/tcp --permanent
	firewall-cmd --add-port 8082/tcp --permanent
	firewall-cmd --add-port 8083/tcp --permanent
        firewall-cmd --reload
        ;;
    UBUNTU)
        # firewall
        sudo ufw enable
        sudo ufw default deny
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw allow 8009/tcp
        sudo ufw allow 8080/tcp
        sudo ufw allow 8081/tcp
        sudo ufw allow 8082/tcp
        sudo ufw allow 8083/tcp
        ;;
esac

if ! systemctl status firewalld|egrep '(could not be found|disabled;)'; then
fi

# Get dirs ready
mkdir -p /opt/logs
mkdir -p /opt/app
mkdir -p /opt/webs

# jdk and symbolic link
cd /opt
echo "Extracts jdk"
for j in ./packages/jdk*.tar.gz ; do
    tar zxf $j 
done
# Make the latest version default
_jdk=`find -type d -name "jdk1.*"|sort -V|tail -1`
echo "$_jdk is default jdk"
ln -sf $_jdk ./jdk

# Maven
cd /opt
echo "Extracts maven"
for m in ./packages/apache-maven*.tar.gz ; do
    tar zxf $m
done
# Make the latest version default
_maven=`find -type d -name apache-maven*|sort -V|tail -1`
echo "$_maven is default maven"
ln -sf $_maven ./maven

# Configure tomcats app/webs
cd /opt/app
echo "Extracts tomcat*.zip"
for tzip in ../packages/apache-tomcat-*.zip ; do
    unzip -q $tzip
done
echo "Extracts tomcat*.tar.gz"
for ttar in ../packages/apache-tomcat-*.tar.gz ; do
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
    sed -i '/<Context>/a\    <Resources allowLinking="true" cachingAllowed="true" cacheMaxSize="102400" \/>' ./conf/context.xml    
    sed -i 's/%s %b/%s %b %D %S %{X-Forwarded-For}i %{Referer}i/g' ./conf/server.xml
    ls -l
    _webdir="/opt/webs/app-`echo $tm|sed 's/apache-tomcat-//g'`"
    mkdir -p $_webdir
    mv ./conf $_webdir
    mv ./logs $_webdir
    mv ./temp $_webdir
    mv ./webapps $_webdir
    mv ./work $_webdir
    cd ..
done

# Make the latest version default
_tomcat=`find -type d -name "apache-tomcat-*"|sort -V|tail -1`
ln -sf $_tomcat ./tomcat

# Get nginx ready
yum install nginx -y
systemctl enable nginx
systemctl start nginx

# Install rpms
cd /opt/packages
yum localinstall *.rpm

