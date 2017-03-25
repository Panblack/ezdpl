#!/bin/bash
echo "`uptime; ip addr show eth0; echo`" | mail -s "`hostname -s` to HAPROXY master." recv@example.com
