#!/bin/bash
/bin/cp -p /etc/security/limits.conf /etc/security/limits.conf.bak.`date +%F`
/bin/cp -p /var/spool/cron/root /var/spool/cron/root.bak.`date +%F`
