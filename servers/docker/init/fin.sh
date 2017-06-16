#!/bin/bash
wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable docker
systemctl start docker
