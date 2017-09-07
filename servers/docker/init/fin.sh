#!/bin/bash
curl -o /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
killall yum
kill -9 `ps aux|grep yum|grep -v grep |awk '{print $2}'`
rm /var/run/yum.pid -f
yum install -y docker-ce
systemctl enable docker
systemctl start docker
