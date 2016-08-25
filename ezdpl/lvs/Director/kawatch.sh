#!/bin/bash
# Print realtime keepalived VRRP Multicast Info.
tcpdump -vvv -n -i eth0 dst 224.0.0.18
