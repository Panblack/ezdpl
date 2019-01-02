#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE

# Prepare php root path & user
mkdir -p $_PHP_ROOT
useradd $_PHP_USER

echo
echo "Install/Update llibcurl-deve libxml2 libxml2-devel ..."
yum install libcurl-devel libxml2 libxml2-devel libevent-devel -y
yum update  libxml2 libxml2-devel -y
echo
echo "Download php..."
cd /opt/
wget -rq -O ${_PHP_VERSION}.tar.gz http://cn2.php.net/get/${_PHP_VERSION}.tar.gz/from/this/mirror
if [[ -d ${_PHP_VERSION} ]]; then
    mv ${_PHP_VERSION} ${_PHP_VERSION}.`date +%F_%H%M%S`
fi
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
echo "Make & Install php7..."
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
sed -i 's/user = nobody/user = '${_PHP_USER}'/g' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/group = nobody/group = '${_PHP_USER}'/g' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/include=NONE/include=\/usr\/local/g' /usr/local/etc/php-fpm.conf
echo "<?php phpinfo(); ?>" >> ${_PHP_ROOT}/index.info.php
chmod -R 770 $_PHP_ROOT
chown -R ${_PHP_USER}:${_PHP_USER} $_PHP_ROOT

# Change nginx user
sed -i '/user *nginx;/d' /etc/nginx/nginx.conf
sed -i '/1/i\user '${_PHP_USER}'' /etc/nginx/nginx.conf
nginx -t && service nginx restart

echo
echo "Start php-fpm service..."
systemctl daemon-reload
chkconfig php-fpmd on
service php-fpmd start 
service php-fpmd status

echo 
echo "Check if workerman compatible"
php /usr/local/bin/workerman.check.php
echo 
echo "Finished."

