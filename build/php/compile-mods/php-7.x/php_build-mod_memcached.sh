#!/usr/bin/env bash

mkdir -p build/pecl/ && cd build/pecl/ && rm -fr memcached

git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git memcached && cd memcached

phpize && ./configure --enable-memcached-json

make && ${CMD_PRE} make install
