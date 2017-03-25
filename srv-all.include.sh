# scripts for srv-all:

   #ssh -p$_port root@$_host 'cat /proc/sys/kernel/kptr_restrict'
   #ssh -p$_port root@$_host 'killall -9 yum ; yum update bash openssh openssl openssl-devel bash --enablerepo=CentOS* -y ; service sshd restart'
   #ssh -p$_port root@$_host 'killall -9 yum && yum clean all && yum install -y dstat & '
   #scp -p -P $_port ./servers/common/init/files/usr/local/bin/log-iptraf.sh root@$_host:/usr/local/bin/
   #ssh -p$_port root@$_host 'yum install dos2unix -y '
   #ssh -p$_port root@$_host 'sed -i "s#/usr/bin/du -h --max-depth=1#/usr/bin/du -hx --max-depth=1#g" /etc/profile.d/alias_custom.sh'
   #ssh -p$_port root@$_host 'if ! grep -E "nnoremap Q :q$" ~/.vimrc ;then echo "nnoremap Q :q!" >> ~/.vimrc; fi; tail -2 ~/.vimrc'
   #ssh -p$_port root@$_host 'sed -i "s/nnoremap Q :q/nnoremap Q :q\!/g" /root/.vimrc'
   #ping -c 10 -i 0.2 $_host | tee -a  /home/dpl/srv-ping.log
   #ssh -p$_port root@$_host grep "Group writable directory" /var/log/maillog|tail 
   #ssh -p$_port root@$_host 'yum install -y bash openssl'

   #scp -P$_port -p servers/common/init/files/usr/local/bin/lvsrs.sh root@$_host:/usr/local/bin/
   #scp -P$_port -p servers/common/init/files/etc/lvs_vip.conf root@$_host:/etc/
   #ssh -p$_port root@$_host 'grep "Network is down" /var/log/messages*'
   #ssh -p$_port root@$_host 'grep Port /etc/ssh/sshd_config; cat /etc/sysconfig/iptables |grep 2139'
   #ssh -p$_port root@$_host 'grep " 404 " /opt/logs/localhost_access_log.${_date}.txt ' >> ~/404.txt
   #ssh -p$_port root@$_host 'ls -l /|grep drwxrw '
   #ssh -p$_port root@$_host 'sed -i '/proxy=/d' /etc/yum.conf '
   #ssh -p$_port root@$_host 'sysctl -a 2>/dev/null |grep net.netfilter.nf_conntrack_tcp_timeout_established'
   #ssh -p$_port root@$_host 'last |grep reboot|grep "Thu Jun  2" '
   #ssh -p$_port root@$_host 'cat /etc/bashrc|egrep "alias " '
   #ssh -p$_port root@$_host 'ping -c 3 api.weixin.qq.com'
   #ssh -p$_port root@$_host 'ip a ;echo ;ip route; echo ;cat /etc/sysconfig/network-scripts/ifcfg-eth0; echo ; cat /etc/sysconfig/network-scripts/ifcfg-eth1'

   #scp -P$_port ./servers/common/init/files/etc/profile.d/alias_custom.sh root@$_host:/etc/profile.d/  
   #scp -P$_port /opt/ezdpl/common/init/files/root/.vimrc root@$_host:/root/

   #./ezdpl Y $_host:$_port common/grep
   #./ezdpl Y $_host:$_port common/ps1
   #./ezdpl Y $_host:$_port common/zabbix
   #./ezdpl Y $_host:$_port common/openssl_bash
   #./ezdpl Y $_host:$_port common/mount
   #./ezdpl Y $_host:$_port common/scripts

