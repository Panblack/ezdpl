#!/bin/bash
_cron="*  */1 * * * /usr/local/bin/ban_ssh.sh"
sed -i /"ban_ssh"/d /var/spool/cron/root
echo "$_cron" >> /var/spool/cron/root
