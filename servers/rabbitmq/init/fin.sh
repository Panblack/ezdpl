#!/bin/bash
## rpm install
_version="3.6.9"
echo http://www.rabbitmq.com/install-rpm.html
echo
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server-3.6.9-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum install -y rabbitmq-server-3.6.9-1.el7.noarch.rpm
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
rabbitmqctl add_user rmquser user_pass
rabbitmqctl add_user rmqadmin admin_pass
rabbitmqctl set_user_tags rmqadmin administrator
rabbitmqctl set_user_tags guest
rabbitmqctl set_permissions -p / rmquser ".*" ".*" ".*"
rabbitmqctl start_app

echo "`date +%F_%T` rabbitmq/init " >> /tmp/ezdpl.log
