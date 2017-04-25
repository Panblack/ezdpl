#!/bin/bash
/etc/init.d/haproxy start
/etc/init.d/sendmail start

echo "`date +%F_%T` haproxy/init " >> /tmp/ezdpl.log

