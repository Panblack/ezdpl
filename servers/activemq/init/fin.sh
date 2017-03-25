#!/bin/bash
cd /opt
for x in ./packages/apache-activemq-*-bin.tar.gz; do
    tar zxf $x ;
done

# make the latest version default
_activemq=`find -type d -name "apache-activemq-*"|sort -V|tail -1`
ln -sf $_activemq ./activemq
sed -i "s/admin:admin/admin:adminPassword/g" /opt/activemq/conf/jetty-realm.properties
sed -i "s/user:user/user:userPassword/g" /opt/activemq/conf/jetty-realm.properties

iptables-iport a "8161 61616"
