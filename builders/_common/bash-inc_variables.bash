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
export BIN_PHPIZE="$(which phpize 2> /dev/null)"
export VER_PHP="$(${BIN_PHP} -v 2> /dev/null | head -n 1 | cut -d' ' -f2)"
export VER_PHP_ON_7=""
export VER_PHP_ON_5=""
export VER_PHP_ON_UNSU=""
export VER_ENV_DIST="Ubuntu"
export VER_ENV_SUPPORT="wily,vivid,trusty,precise"
export VAR_ENV_SCRIBE_PATH="${scribe_packaged:-x}"
export VAR_ENV_SCRIBE_PATH_DEFAULT=".scribe-package.yml"
export VAR_ENV_SCRIBE_PREFIX="scr_pkg_"
export VAR_ENV_SCRIBE_CHECK="${VAR_ENV_SCRIBE_PREFIX}phpexts_req,${VAR_ENV_SCRIBE_PREFIX}syspkgs_req,${VAR_ENV_SCRIBE_PREFIX}ci_send_req,${VAR_ENV_SCRIBE_PREFIX}phpincs_req"
export COV_PATH="build/logs/clover.xml"
export INC_MODS_PATH="$(readlink -f ${SCRIPT_COMMON_RPATH}/../_php-mods/)"
export INC_MODS_FILE="php-mods_make-"
export INC_SYSR_PATH="$(readlink -f ${SCRIPT_COMMON_RPATH}/../_ext-deps/)"
export INC_SYSR_FILE="ext-deps_make-"
export INC_INCS_PATH="$(readlink -f ${SCRIPT_COMMON_RPATH}/../_php-incs/)"
export INC_INCS_FILE="php-incs_"
export INC_SYMF_PATH="$(readlink -f ${SCRIPT_COMMON_RPATH}/../_app-make/)"
export INC_SYMF_FILE="app-make_"

if [ ${VAR_ENV_SCRIBE_PATH}} == "~" ]
then
	VAR_ENV_SCRIBE_PATH="${VAR_ENV_SCRIBE_PATH_DEFAULT}"
fi

if [ ${VER_PHP:0:1} == "7" ]
then
    VER_PHP_ON_7="true"
elif [ ${VER_PHP:0:1} == "5" ]
then
    VER_PHP_ON_5="true"
else
    VER_PHP_ON_UNSU="true"
fi

export COLOR_BLACK='\e[0;30m'
export COLOR_RED='\e[0;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_YELLOW='\e[0;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_WHITE='\e[0;37m'

export COLOR_L_BLACK='\e[0;90m'
export COLOR_L_RED='\e[0;91m'
export COLOR_L_GREEN='\e[0;92m'
export COLOR_L_YELLOW='\e[0;93m'
export COLOR_L_BLUE='\e[0;94m'
export COLOR_L_PURPLE='\e[0;95m'
export COLOR_L_CYAN='\e[0;96m'
export COLOR_L_WHITE='\e[0;97m'

export COLOR_B_BLACK='\e[1;30m'
export COLOR_B_RED='\e[1;31m'
export COLOR_B_GREEN='\e[1;32m'
export COLOR_B_YELLOW='\e[1;33m'
export COLOR_B_BLUE='\e[1;34m'
export COLOR_B_PURPLE='\e[1;35m'
export COLOR_B_CYAN='\e[1;36m'
export COLOR_B_WHITE='\e[1;97m'

export COLOR_U_BLACK='\e[4;30m'
export COLOR_U_RED='\e[4;31m'
export COLOR_U_GREEN='\e[4;32m'
export COLOR_U_YELLOW='\e[4;33m'
export COLOR_U_BLUE='\e[4;34m'
export COLOR_U_PURPLE='\e[4;35m'
export COLOR_U_CYAN='\e[4;36m'
export COLOR_U_WHITE='\e[4;97m'

export COLOR_BG_BLACK='\e[40m'
export COLOR_BG_RED='\e[41m'
export COLOR_BG_GREEN='\e[42m'
export COLOR_BG_YELLOW='\e[43m'
export COLOR_BG_BLUE='\e[44m'
export COLOR_BG_PURPLE='\e[45m'
export COLOR_BG_CYAN='\e[46m'
export COLOR_BG_WHITE='\e[47m'

export C_RST='\e[0m'

export C_TXT_DEFAULT="${COLOR_WHITE}"
export C_PRE_DEFAULT="${COLOR_L_WHITE}"
export C_HDR_DEFAULT="${COLOR_WHITE}"
export C_TXT=""
export C_PRE=""
export C_HDR=""
export L_MAX=100
export O_NL=true
export O_PRE=true
export O_SPACE=1
export O_SEC_SPACE=1

# EOF #
