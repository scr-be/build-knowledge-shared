#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export CMD_PRE=""
export CMD_ENV=""
export BIN_PHPENV="$(which phpenv 2> /dev/null)"
export VER_PHPENV="$(${BIN_PHPENV} -v 2> /dev/null | cut -d' ' -f2 2> /dev/null)"
export BIN_PHP="$(which php 2> /dev/null)"
export VER_PHP="$(${BIN_PHP} -v 2> /dev/null | head -n 1 | cut -d' ' -f2)"
export VER_PHP_ON_7=""
export VER_PHP_ON_5=""
export VER_PHP_ON_UNSU=""
export VER_ENV_DIST="Ubuntu"
export VER_ENV_SUPPORT="wily,vivid,trusty"
export VAR_ENV_SCRIBE_PATH="${scribe_packaged:-x}"
export VAR_ENV_SCRIBE_PATH_DEFAULT=".scribe-package.yml"
export VAR_ENV_SCRIBE_PREFIX="scr_pkg_"
export VAR_ENV_SCRIBE_CHECK="${VAR_ENV_SCRIBE_PREFIX}phpexts_req,${VAR_ENV_SCRIBE_PREFIX}syspkgs_req,${VAR_ENV_SCRIBE_PREFIX}ci_send_req,${VAR_ENV_SCRIBE_PREFIX}phpincs_req"

if [ ${VAR_ENV_SCRIBE_PATH}} == "~" ]
then
	VAR_ENV_SCRIBE_PATH="${VAR_ENV_SCRIBE_PATH_DEFAULT}"
fi

if [ ${VER_PHP:0:1} == "7" ]
then
    VER_PHP_ON_5="true"
elif [ ${VER_PHP:0:1} == "5" ]
then
    VER_PHP_ON_5="true"
else
    VER_PHP_ON_UNSU="true"
fi

# EOF #
