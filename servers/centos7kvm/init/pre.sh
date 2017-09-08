#!/bin/bash
yum clean all
yum install -y qemu-kvm qemu-img libvirt libvirt-client bridge-utils nfs
brctl addbr br0
brctl show
brctl stp br0 on
_ifcfg_eth=`ls /etc/sysconfig/network-scripts/ifcfg-e*`
systemctl enable libvirtd nfs
systemctl start libvirtd

