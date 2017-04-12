#!/bin/bash
echo "rabbitmqctl add_user user pass"
echo "rabbitmqctl add_user admin_user admin_pass"
echo "rabbitmqctl set_user_tags guest"
echo "rabbitmqctl set_user_tags admin_user administrator"

