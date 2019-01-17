#!/bin/bash
source /usr/local/bin/release.include
echo $_RELEASE
if [[ -z $_PHP_USER ]]; then
    # Only applies to lnmp. 
    # For apache _PHP_USER=apache or _PHP_USER=www-data
    _PHP_USER=nginx
fi

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
yum install -y gcc autoconf re2c bison bison-devel libzip libzip-devel openssl openssl-devel libcurl libcurl-devel libxml2 libxml2-devel libevent libevent-devel   libXpm-devel zlib-devel libwebp-devel libjpeg-devel libpng-devel freetype-devel gd-devel
yum update -y libxml2 libxml2-devel openssl openssl-devel

echo
echo "Download php..."
cd /opt/
_backup_dir="/opt/backup/`date +%Y%m%d_%H%M%S`"
mkdir -p $_backup_dir

if [[ -d ${_PHP_VERSION} ]]; then
    /bin/mv ${_PHP_VERSION} $_backup_dir
    /bin/cp -p /etc/nginx/nginx.conf $_backup_dir
    /bin/cp -p /usr/local/lib/php.ini $_backup_dir
    /bin/cp -p /usr/local/etc/php-fpm.conf $_backup_dir
    /bin/cp -p /usr/local/etc/php-fpm.d/www.conf $_backup_dir
fi
curl -O ${_PHP_VERSION}.tar.gz http://cn2.php.net/get/${_PHP_VERSION}.tar.gz/from/this/mirror
tar zxf ${_PHP_VERSION}.tar.gz
cd /opt/${_PHP_VERSION} 
pwd
echo "Configure ${_PHP_VERSION}..."
echo        >> /tmp/php-configure.log
date +%F_%T >> /tmp/php-configure.log
./configure      \
    --enable-fpm  \
    --enable-zip   \
    --enable-pcntl  \
    --enable-sockets \
    --enable-mbstring \
    --with-zlib        \
    --with-curl         \
    --with-openssl       \
    --with-mysqli         \
    --with-gd                \
    --with-zlib-dir=/usr      \
    --with-webp-dir=/usr/lib64 \
    --with-png-dir=/usr/lib64   \
    --with-jpeg-dir=/usr/lib64   \
    --with-xpm-dir=/usr/lib64     \
    --with-freetype-dir=/usr/lib64 \
    --with-fpm-user=${_PHP_USER} --with-fpm-group=${_PHP_USER} 2>&1 |tee -a /tmp/php-configure.log   

echo "php configure finished. See log /tmp/php-configure.log"
echo
echo "Make & Install ${_PHP_VERSION}..."
if make --quiet ; then
    echo        >> /tmp/php-install.log
    date +%F_%T >> /tmp/php-install.log
    make install 2>&1 | tee -a /tmp/php-install.log
    echo
    echo "${_PHP_VERSION} installed. See log /tmp/php-install.log"
else
    echo 
    echo "failed to make ${_PHP_VERSION}."
    exit 1
fi

echo
echo "Prepare ${_PHP_VERSION} config files..."
/bin/cp /opt/${_PHP_VERSION}/sapi/fpm/php-fpm      /usr/local/bin
/bin/cp /opt/${_PHP_VERSION}/php.ini-production    /usr/local/lib/php.ini
/bin/cp /usr/local/etc/php-fpm.conf.default        /usr/local/etc/php-fpm.conf
/bin/cp /usr/local/etc/php-fpm.d/www.conf.default  /usr/local/etc/php-fpm.d/www.conf
sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /usr/local/lib/php.ini
sed -i 's/user = nobody/user = '${_PHP_USER}'/g'   /usr/local/etc/php-fpm.d/www.conf
sed -i 's/group = nobody/group = '${_PHP_USER}'/g' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/user = nginx/user = '${_PHP_USER}'/g'    /usr/local/etc/php-fpm.d/www.conf
sed -i 's/group = nginx/group = '${_PHP_USER}'/g'  /usr/local/etc/php-fpm.d/www.conf
sed -i '/access.log =/a\access.log = \/usr\/local\/var\/log\/$pool.access.log' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/include=NONE/include=\/usr\/local/g'     /usr/local/etc/php-fpm.conf

_php_info='
<p align="center">Good Luck!! :)</p>
<?php phpinfo(); ?>
<p>
<p>GD INFO</p>
<?php
if (extension_loaded("gd")) {
   echo "gd ok<br>";
   foreach(gd_info() as $cate=>$value)
       echo "$cate: $value<br>";
}else
    echo "gd not ok";
?>
'

echo "$_php_info" >> ${_PHP_ROOT}/example/index.info.php
chown -R ${_PHP_USER}:${_PHP_USER} $_PHP_ROOT
chown -R ${_PHP_USER}:${_PHP_USER} /var/log/nginx
chown -R ${_PHP_USER}:${_PHP_USER} /var/cache/nginx
chown -R ${_PHP_USER}:${_PHP_USER} /usr/share/nginx/html
sed -i 's/create 640 nginx adm/create 640 '${_PHP_USER}' adm/g' /etc/logrotate.d/nginx
chmod -R 770 $_PHP_ROOT
chmod -R 770 /usr/share/nginx/html

# Change nginx user
sed -i '/^user /d' /etc/nginx/nginx.conf
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
curl -s http://www.example.com/index.info.php
echo "Finished."

### php ext ###
# yum install -y autoconf
#
### mbstring ###
# cd /opt/php-7.3.0/ext/mbstring
# phpize && ./configure --with-php-config=/usr/local/bin/php-config
# make && make install
# 
### openssl ### 
# cd /opt/php-7.3.0/ext/openssl
# cp config0.m4 config.m4
# phpize && ./configure --with-php-config=/usr/local/bin/php-config
# make && make install
#
### zipArchive ###
# libzip >=0.11 for WP Duplicator plug-in
# libzip libzip-devel 0.11: https://koji.fedoraproject.org/koji/buildinfo?buildID=622762
# cd /opt/php-7.3.0/ext/mbstring
# phpize && ./configure --with-php-config=/usr/local/bin/php-config
# make && make install
# 
### php.ini ###
# ls -l /usr/local/lib/php/extensions/no-debug-non-zts-*/
# echo "extension=mbstring.so" >> /usr/local/lib/php.ini
# echo "extension=openssl.so" >> /usr/local/lib/php.ini
#
### restart php ###
# service php-fpmd restart
#
###############

