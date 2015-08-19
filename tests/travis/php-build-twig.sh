#!/bin/bash

mkdir -p build/pecl/ && cd build/pecl/
git clone https://github.com/twigphp/Twig.git twig
cd twig && git checkout v1.18.2 && cd ext/twig
phpize
./configure --enable-twig

make
make install

echo "extension=twig.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
