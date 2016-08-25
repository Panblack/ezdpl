#!/bin/bash
# Description: Add VIP's to interface lo. Originally copied from some blog with some modifications made. 
# Sample /etc/lvs_vip.conf :
# a.b.c.d0 a.b.c.d1 a.b.c.d2

LVS_VIP=`cat /etc/lvs_vip.conf`

case "$1" in
start)
    i=0
    for x in $LVS_VIP;do
#       /sbin/ifconfig lo:$i $x netmask 255.255.255.255 broadcast $x
#       /sbin/route add -host $x dev lo:$i
       /sbin/ip addr add $x/32 dev lo
       /sbin/ip route add $x/32 dev lo
       ((i++))
    done
       echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
       sysctl -p >/dev/null 2>&1
       echo "RealServer Start OK"
       ;;
stop)
    i=0
    for x in $LVS_VIP;do
#       /sbin/ifconfig lo:$i down
#       /sbin/route del $x >/dev/null 2>&1
       /sbin/ip addr del $x/32 dev lo
       /sbin/ip route del $x/32 >/dev/null 2>&1
       ((i++))
    done
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
       echo "RealServer Stoped"
       ;;
*)
       echo "Usage: $0 {start|stop}"
       exit 1
esac
exit 0
