#!/bin/bash
sed -i /sendmail *restart/d /var/spool/cron/root
sed -i /keepalived *start/d /var/spool/cron/root
sed -i /lvs_backend_change.sh/d /var/spool/cron/root
_cron="
0    1 * * * /etc/init.d/sendmail restart &>/dev/null
0    0 * * * /etc/init.d/keepalived start
*/1  * * * * /usr/local/bin/lvs_backend_change.sh"
echo "$_cron" >> /var/spool/cron/root

# Permit forward
cp /etc/sysctl.conf /etc/sysctl.conf.`date +%F_%H%M`
sed -i "s/net.ipv4.ip_forward.*=.*0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
sysctl -p


#iptables , permit web ports, NAT, multicast ...
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.`date +%F_%H%M`

iptables-iport a "80 443 8080" t

/etc/init.d/iptables reload
#SNAT       all  --  10.1.1.0/24          0.0.0.0/0           to:1.2.3.102 
if ! iptables -t nat -nL | egrep "^SNAT.*10\.1\.1\.0.*1\.2\.3\.102" ; then
    iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -o eth0 -j SNAT --to-source 1.2.3.102
fi

#ACCEPT     all  --  0.0.0.0/0            224.0.0.18
if ! iptables -nL | egrep "^ACCEPT.*all.*224.0.0.18" ; then
    iptables -A INPUT -d 224.0.0.18/32 -j ACCEPT 
fi

#ACCEPT forward
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited
iptables -A FORWARD -j ACCEPT

#Restore --reject-with icmp-host-prohibited
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited 
/etc/init.d/iptables save

/etc/init.d/keepalived start
/etc/init.d/sendmail start
