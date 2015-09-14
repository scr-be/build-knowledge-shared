#!/usr/bin/env bash

sudo apt-get remove --purge -y php5-imagick
sudo apt-get install -qq -y --verbose-versions --reinstall imagemagick libmagick++-dev

printf "\n" | pecl install channel://pecl.php.net/imagick-3.3.0RC2

echo "extension=imagick.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
