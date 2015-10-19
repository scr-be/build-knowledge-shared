#!/usr/bin/env bash

if [[ ${TRAVIS} ]] && [[ ${TRAVIS_PHP_VERSION:0:3} != "7.0" ]]; then 
	bin/coveralls -vvv
	bin/ocular code-coverage:upload --format=php-clover build/logs/clover.xml
else
	echo "Skipping code-coverage reporting as not running within Travis."
fi
