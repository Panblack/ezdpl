#!/bin/bash
if [[ -f /etc/security/limits.conf ]]; then
    /bin/cp -p /etc/security/limits.conf /etc/security/limits.conf.bak.`date +%F`
fi
if [[ -f /var/spool/cron/root ]]; then
    /bin/cp -p /var/spool/cron/root /var/spool/cron/root.bak.`date +%F`
fi

