#scon $_host e "cat /etc/*-release"
#ssh -p$_port root@$_host 'yum install -y bash openssl'
#scp -p ./servers/javasrv/init/files/usr/local/bin/tmc root@$_host:/usr/local/bin/
#./ezdpl Y $_host:$_port common/zabbix
