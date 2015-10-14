#!/usr/bin/env bash

mkdir -p build/pecl/ && cd build/pecl/ && rm -fr msgpack

git clone -b php7 https://github.com/msgpack/msgpack-php.git msgpack && cd msgpack

phpize && ./configure

make && ${CMD_PRE} make install
