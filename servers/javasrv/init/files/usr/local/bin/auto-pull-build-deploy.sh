#!/bin/bash
# Auto pull new commit & build & deploy.

cd /home/YourUserName/workspace/YourProject
if git pull|grep "Already up-to-date." ; then
    echo "No new commit. Exit!"
    exit 0
fi
if mvn clean package | grep "BUILD SUCCESS" ; then
    /bin/cp ./target/config.war /home/app/tomcat8/webapps/
    echo "Deploy OK !"
else
    echo "Build FAIL !"
fi
