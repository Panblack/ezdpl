#!/bin/bash
mkdir -p /opt/packages
cd /opt/packages
curl -O https://kojipkgs.fedoraproject.org//packages/libzip/0.11.2/5.fc20/x86_64/libzip-0.11.2-5.fc20.x86_64.rpm
curl -O https://kojipkgs.fedoraproject.org//packages/libzip/0.11.2/5.fc20/x86_64/libzip-devel-0.11.2-5.fc20.x86_64.rpm
_libzip_devel=`rpm -qa|grep 'libzip-devel'`
if [[ $_libzip_devel < 'libzip-devel-0.11.2-5.fc20.x86_64' ]]; then
    yum install -y libzip-0.11.2-5.fc20.x86_64.rpm libzip-devel-0.11.2-5.fc20.x86_64.rpm
fi

