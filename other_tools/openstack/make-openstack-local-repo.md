# 本地建立 openstack-queens 软件源

## 软件源服务器配置

1. 安装一台Centos7服务器（2CPU 2G）
1. 安装apache、wget
1. 批量下载repo文件（只能用mirror.centos.org，国内镜像站都不允许批量下载） 

```
yum install -y httpd wget
systemctl enable httpd
systemctl start httpd
cd /var/www/html/
wget -b --mirror --no-host-directories --no-parent http://mirror.centos.org/centos/7/storage/x86_64/ceph-luminous/
wget -b --mirror --no-host-directories --no-parent http://mirror.centos.org/centos/7/cloud/x86_64/openstack-queens/
wget -b --mirror --no-host-directories --no-parent http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/
```

## Openstack服务器配置

### 编辑openstack服务器的 `/etc/hosts`，添加

`<软件源服务器IP>   mirror.centos.org` 

### 测试软件源服务器

`curl -sSL http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/`

### 创建repo文件

`vim /etc/yum.repos.d/rdo.repo`

内容如下：

```
[centos-ceph-luminous]
name=CentOS-7 - Ceph Luminous
baseurl=http://mirror.centos.org/centos/7/storage/x86_64/ceph-luminous/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage

[centos-openstack-queens]
name=CentOS-7 - OpenStack queens
baseurl=http://mirror.centos.org/centos/7/cloud/x86_64/openstack-queens/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud
exclude=sip,PyQt4

[centos-qemu-ev]
name=CentOS-7 - QEMU EV
baseurl=http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization
```

### 安装packstack

`yum update -y ; yum install -y vim net-tools bash-comm* openstack-packstack`





