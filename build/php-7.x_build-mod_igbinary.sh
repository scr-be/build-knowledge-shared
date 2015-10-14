#!/usr/bin/env bash

mkdir -p build/pecl/ && cd build/pecl/

git clone -b php7-dev-playground1 https://github.com/igbinary/igbinary.git igbinary && cd igbinary

phpize && ./configure --enable-igbinary

make && ${CMD_PRE} make install
