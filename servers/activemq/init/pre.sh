#!/bin/bash
for x in `ps aux|grep java|grep activemq|awk '{print $2}'`; do 
    kill -9 $x
done
cd  /opt/ && rm *activemq* -rf

