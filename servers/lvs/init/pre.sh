#!/bin/bash
yum install -y ipvsadm keepalived sendmail mailx
chkconfig keepalived on
chkconfig sendmail on

