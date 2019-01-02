#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# Prepare php root path & user
if [[ -n $_PHP_ROOT ]] && [[ -n $_PHP_USER ]] && [[ -n $_PHP_VERSION ]]; then
    mkdir -p $_PHP_ROOT
    if ! useradd -d $_PHP_ROOT -s /sbin/nologin $_PHP_USER ;then
         usermod -d $_PHP_ROOT -s /sbin/nologin $_PHP_USER
    fi
else
    echo "Fatal: _PHP_ROOT, _PHP_USER, _PHP_VERSION not configured in /usr/local/bin/release.include."; exit 1 
fi

echo
echo "Install/Update dependencies ..."
yum install gcc openssl openssl-devel libcurl libcurl-devel libxml2 libxml2-devel libevent libevent-devel -y
yum update  libxml2 libxml2-devel -y
echo
echo "Download php..."
cd /opt/
_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir

if [[ -d ${_PHP_VERSION} ]]; then
    /bin/mv ${_PHP_VERSION} $_backup_dir
    /bin/cp -p /etc/nginx/nginx.conf $_backup_dir
    /bin/cp -p /usr/local/php/php.ini $_backup_dir
    /bin/cp -p /usr/local/etc/php-fpm.conf $_backup_dir
    /bin/cp -p /usr/local/etc/php-fpm.d/www.conf $_backup_dir
fi
wget -rq -O ${_PHP_VERSION}.tar.gz http://cn2.php.net/get/${_PHP_VERSION}.tar.gz/from/this/mirror
tar zxf ${_PHP_VERSION}.tar.gz
cd /opt/${_PHP_VERSION} 
pwd
echo "Configure ${_PHP_VERSION}..."
./configure \
    --enable-fpm \
    --enable-pcntl \
    --enable-sockets \
    --with-mysqli \
    --with-fpm-user=${_PHP_USER} \
    --with-fpm-group=${_PHP_USER} \
    --with-zlib \
    --with-curl 
echo
echo "Make & Install ${_PHP_VERSION}..."
if make; then
    make install
    echo
    echo "${_PHP_VERSION} installed successfully."
else
    echo 
    echo "failed to install ${_PHP_VERSION}."
    exit 1
fi

echo
echo "Prepare ${_PHP_VERSION} config files..."
/bin/cp /opt/${_PHP_VERSION}/sapi/fpm/php-fpm      /usr/local/bin
/bin/cp /opt/${_PHP_VERSION}/php.ini-production    /usr/local/php/php.ini
/bin/cp /usr/local/etc/php-fpm.conf.default        /usr/local/etc/php-fpm.conf
/bin/cp /usr/local/etc/php-fpm.d/www.conf.default  /usr/local/etc/php-fpm.d/www.conf
sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /usr/local/php/php.ini
sed -i 's/user = nobody/user = '${_PHP_USER}'/g'   /usr/local/etc/php-fpm.d/www.conf
sed -i 's/group = nobody/group = '${_PHP_USER}'/g' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/user = nginx/user = '${_PHP_USER}'/g'    /usr/local/etc/php-fpm.d/www.conf
sed -i 's/group = nginx/group = '${_PHP_USER}'/g'  /usr/local/etc/php-fpm.d/www.conf
sed -i 's/include=NONE/include=\/usr\/local/g'     /usr/local/etc/php-fpm.conf

echo "<?php phpinfo(); ?>" >> ${_PHP_ROOT}/example/index.info.php
chown -R ${_PHP_USER}:${_PHP_USER} $_PHP_ROOT
chmod -R 770 $_PHP_ROOT

# Change nginx user
sed -i '/user *nginx;/d' /etc/nginx/nginx.conf
sed -i '1i\user '${_PHP_USER}';' /etc/nginx/nginx.conf
nginx -t && service nginx restart

echo
echo "Start php-fpm service..."
systemctl daemon-reload
chkconfig php-fpmd on
service php-fpmd start 
service php-fpmd status

echo 
echo "Check if workerman compatible"
php /tmp/workerman.check.php
echo 
echo "php info"
curl -s http://www.example.com/index.info.php | grep enabled
echo "Finished."

