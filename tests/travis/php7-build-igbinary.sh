#!/bin/sh

mkdir -p build/pecl/ && cd build/pecl/
git clone https://github.com/igbinary/igbinary.git igbinary
cd igbinary && git checkout -b php7-dev-playground1 origin/php7-dev-playground1
phpize
./configure --enable-igbinary

make
make install

echo "extension=igbinary.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
