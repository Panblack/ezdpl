#!/bin/bash
# for notify_master in keepalived.conf
echo "`uptime; ip addr; echo`" | mail -s "`hostname -s` to LVS master." recv@example.com

