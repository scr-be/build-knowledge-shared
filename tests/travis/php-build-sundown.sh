#!/usr/bin/env bash

pecl install channel://pecl.php.net/sundown-0.3.8

echo "extension=sundown.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
