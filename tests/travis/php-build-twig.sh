#!/bin/sh

mkdir -p build/temp/ && cd build/temp/
git clone https://github.com/twigphp/Twig.git twig
cd twig && git checkout v1.18.1 && cd ext/twig
phpize
./configure --enable-twig

make
make install

echo "extension=twig.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
