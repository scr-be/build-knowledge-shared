#!/bin/bash

pecl install channel://pecl.php.net/msgpack-0.5.6

echo "extension=msgpack.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
