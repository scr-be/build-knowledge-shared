#!/usr/bin/env bash

${CMD_PRE} apt-get remove --purge -y php5-imagick
${CMD_PRE} apt-get install -qq -y --verbose-versions --reinstall imagemagick libmagick++-dev

printf "\n" | ${CMD_PRE} pecl install channel://pecl.php.net/imagick-3.3.0RC2
