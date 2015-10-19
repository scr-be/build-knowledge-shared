#!/usr/bin/env bash

readonly SCRIPT_REAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

phpenv config-add ${SCRIPT_REAL_PATH}/php_write-cfg_timezone.ini
phpenv rehash
