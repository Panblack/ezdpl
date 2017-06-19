#!/bin/bash
cd /opt/tomcat/logs && pwd && find -type f -mtime +30 -exec gzip {} \;

