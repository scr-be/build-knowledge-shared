#!/bin/sh

mkdir -p build/pecl/ && cd build/pecl/
git clone -b php7-dev-playground1 https://github.com/igbinary/igbinary.git igbinary
cd igbinary && phpize && ./configure --enable-igbinary

make && make install

echo "extension=igbinary.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
