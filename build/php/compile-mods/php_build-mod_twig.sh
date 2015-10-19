#!/usr/bin/env bash

readonly PARENT_SCRIPT_REAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${PARENT_SCRIPT_REAL_PATH}/_php_build-mod_common.sh
