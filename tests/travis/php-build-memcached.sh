#!/usr/bin/env bash

sudo apt-get remove --purge -y php5-memcached
sudo apt-get install -qq -y --verbose-versions --reinstall libjson-c2 php5-json

mkdir -p build/pecl/ && cd build/pecl/
wget http://pecl.php.net/get/memcached-2.2.0.tgz
tar xzf memcached-2.2.0.tgz
cd memcached-2.2.0/

phpize
./configure --enable-memcached-igbinary --enable-memcached-json --enable-memcached-msgpack

make
make install

echo "extension=memcached.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
