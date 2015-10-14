#!/usr/bin/env bash

mkdir -p build/pecl/ && cd build/pecl/

git clone -b v1.22.3 https://github.com/twigphp/Twig.git twig && cd twig/etc/twig

phpize && ./configure --enable-twig

make && ${CMD_PRE} make install
