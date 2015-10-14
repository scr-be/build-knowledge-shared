#!/usr/bin/env bash

mkdir -p build/pecl/ && cd build/pecl/ && rm -fr imagick

git clone -b phpseven https://github.com/mkoppanen/imagick.git imagick && cd imagick

phpize && ./configure

make && ${CMD_PRE} make install
