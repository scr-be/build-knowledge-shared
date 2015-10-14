#!/usr/bin/env bash

${CMD_PRE} apt-get remove --purge -y php5-memcached
${CMD_PRE} apt-get install -qq -y --verbose-versions --reinstall libjson-c2 php5-json

mkdir -p build/pecl/ && cd build/pecl/
wget http://pecl.php.net/get/memcached-2.2.0.tgz && tar xzf memcached-2.2.0.tgz && cd memcached-2.2.0/

phpize && ./configure --enable-memcached-igbinary --enable-memcached-json --enable-memcached-msgpack

make && ${CMD_PRE} make install
