#scon $_host e "cat /etc/*-release"
#ssh -p$_port root@$_ip 'yum install -y bash openssl'
#scp -p ./servers/javasrv/init/files/usr/local/bin/tmc $_user@$_ip:/usr/local/bin/
#./ezdpl Y $_ip:$_port common/zabbix
ssh -p$_port root@$_ip 'uname -a'

