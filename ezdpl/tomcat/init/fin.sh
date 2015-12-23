#!/bin/bash
_env="
export JAVA_HOME=/opt/jdk1.7
export JRE_HOME=$JAVA_HOME/jre
export CATALINA_HOME=/opt/tomcat7
export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
"
sed -i /"JAVA_HOME"/d /etc/profile
sed -i /"JRE_HOME"/d /etc/profile
sed -i /"CATALINA_HOME"/d /etc/profile
echo "$_env" >> /etc/profile
service iptables restart

