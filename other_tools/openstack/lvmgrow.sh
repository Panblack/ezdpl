#!/bin/bash
set -u
_log_file="/var/log/lvmgrow.log"
the_root_device='/dev/vda'
the_dynamic_partition='3'
the_dynamic_partition_path="${the_root_device}${the_dynamic_partition}"
the_root_vgname='centos'
the_root_lvname='root'

date +%F_%T >> $_log_file
echo "fdisk: new partition " >> $_log_file
the_root_lvpath="/dev/${the_root_vgname}/${the_root_lvname}"
(echo n; echo p; echo ; echo ; echo; echo t; echo $the_dynamic_partition; echo 8e; echo w) | fdisk ${the_root_device} >> $_log_file
sync; sync; sync
partprobe  >> $_log_file
sync; sync; sync
echo "lsblk" >> $_log_file
lsblk        >> $_log_file
echo "pvcreate" >> $_log_file
pvcreate $the_dynamic_partition_path   >> $_log_file
sync; sync; sync
echo "vgextend" >> $_log_file
vgextend $the_root_vgname $the_dynamic_partition_path   >> $_log_file 
sync; sync; sync
echo "lvextend" >> $_log_file
lvextend $the_root_lvpath $the_dynamic_partition_path  >> $_log_file
sync; sync; sync
echo "xfs_grow" >> $_log_file
xfs_growfs $the_root_lvpath  >> $_log_file
sync; sync; sync
date +%F_%T >> $_log_file

