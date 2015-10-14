#!/usr/bin/env bash

readonly SCRIPT_SELF_PATH="${0}"
readonly SCRIPT_SELF_BASE="$(basename ${0})"
readonly SCRIPT_REAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PHP_VERSION_MAJOR_MINOR="$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1 | grep -o '[0-9]\.[0-9]\.[0-9]' | head -c 3)"
readonly PHP_MODULE="$(basename ${SCRIPT_SELF_BASE:14} .sh)"

if [ ${TRAVIS} ] && [ $(which phpenv) ]; then
    RUN_ENV="Travis-CI (PHPENV)"
    export CMD_PRE=""
elif [ $(which phpenv) ]; then
    RUN_ENV="Local (PHPENV)"
    export CMD_PRE=""
else
    RUN_ENV="Local (System)"
    export CMD_PRE="sudo "
fi

echo "Enviornment  : ${RUN_ENV}"
echo "PHP Version  : ${PHP_VERSION_MAJOR_MINOR}"
echo "Module Name  : ${PHP_MODULE}"

if [ ${PHP_VERSION_MAJOR_MINOR:0:1} == "7" ]; then
    RUN_SCRIPT_PATH="${SCRIPT_REAL_PATH}/php-7.x/${SCRIPT_SELF_BASE}"
elif [ ${PHP_VERSION_MAJOR_MINOR:0:1} == "5" ]; then
    RUN_SCRIPT_PATH="${SCRIPT_REAL_PATH}/php-5.x/${SCRIPT_SELF_BASE}"
else
    echo "ERROR: Unsupported version of PHP!"
    exit
fi

if [ -e ${RUN_SCRIPT_PATH} ]; then
    echo "Build Script : ${RUN_SCRIPT_PATH}"
    bash ${RUN_SCRIPT_PATH}
else
    echo "ERROR: Required script \"${RUN_SCRIPT_PATH}\" does not exist!"
    exit -1
fi

if [ "$(php -m 2> /dev/null | grep ${PHP_MODULE} && echo $?)" ]; then
    echo "Extension ${PHP_MODULE} already loaded. Skipping INI config."
else
    if [ $(which phpenv) ]; then
        echo "Writing extension=${PHP_MODULE} to PHPENV INI file"
        echo "extension=${PHP_MODULE}.so" | tee -a ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
    else
        echo "Auto-enabling extensions is only supported in phpenv environments."
        echo "You need to add \"extension=${PHP_MODULE}.so\" to enable the extension."
    fi
fi