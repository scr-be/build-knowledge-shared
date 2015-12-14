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

export DIR_CWD="$(pwd)"
export TMP_DIR="$(readlink -m "${DIR_CWD}/build")"

export LOG_ALL=()
export LOG_BUF=()
export LOG_DIR="$(getReadyTempPath "${TMP_DIR}/logs/builder")"
export LOG_GEN="$(getReadyTempPath "${LOG_DIR}")"
export LOG_EXT="$(getReadyTempPath "${LOG_DIR}/ext")"
export LOG_APP="$(getReadyTempPath "${LOG_DIR}/sym")"
export LOG_ENV="$(getReadyTempPath "${LOG_DIR}/env")"

export BLD_ALL=()
export BLD_DIR="$(getReadyTempPath "${TMP_DIR}/work/builder")"
export BLD_GEN="$(getReadyTempPath "${BLD_DIR}")"
export BLD_EXT="$(getReadyTempPath "${BLD_DIR}/ext")"
export BLD_APP="$(getReadyTempPath "${BLD_DIR}/sym")"
export BLD_ENV="$(getReadyTempPath "${BLD_DIR}/env")"

export BIN_PECL="$(which pecl)"
export BIN_CURL="$(which curl)"
export BIN_TAR="$(which tar)"
export BIN_MAKE=$(which make)
export BIN_GIT=$(which git)
export BIN_PHP="$(which php)"
export BIN_PHPENV="$(which phpenv)"
export BIN_PHPIZE=$(which phpize)

export VER_PHP="$(getVersionOfPhp)"
export VER_PHPENV="$(getVersionOfPhpEnv)"
export VER_PHPAPI_ENG="$(getVersionOfPhpEngApi)"
export VER_PHPAPI_MOD="$(getVersionOfPhpModApi)"

export VER_PHP_ON_7=""
export VER_PHP_ON_5=""
export VER_PHP_ON_UNSU=""

export VER_ENV_DIST_SUPPORTED="wily,vivid,trusty,precise"

export PKG_YML_FILEPATH=".package.yml"
export PKG_PRE_VARIABLE="scr_pkg_"
export PKG_ENV_VARIABLE="${build_package:-x}"
export PKG_REQ_VARIABLE="${PKG_PRE_VARIABLE}env_make,${PKG_PRE_VARIABLE}app_prep,${PKG_PRE_VARIABLE}app_post,${PKG_PRE_VARIABLE}env_post,${PKG_PRE_VARIABLE}php_exts,${PKG_PRE_VARIABLE}env_prep,${PKG_PRE_VARIABLE}env_post,${PKG_PRE_VARIABLE}php_conf"

export COV_PATH="$(readlink -m ${DIR_CWD}/build/logs/clover.xml)"

export INC_PHP_EXTS_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_php-exts/)"
export INC_PHP_EXTS_FILE="php-exts_"
export INC_PHP_CONF_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_php-conf/)"
export INC_PHP_CONF_FILE="php-conf_"
export INC_ENV_MAKE_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_env-make/)"
export INC_ENV_MAKE_FILE="env-make_"
export INC_ENV_PREP_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_env-prep/)"
export INC_ENV_PREP_FILE="env-prep_"
export INC_ENV_POST_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_env-post/)"
export INC_ENV_POST_FILE="env-post_"
export INC_APP_PREP_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_app-prep/)"
export INC_APP_PREP_FILE="app-prep_"
export INC_APP_POST_PATH="$(readlink -m ${SCRIPT_COMMON_RPATH}/../_app-post/)"
export INC_APP_POST_FILE="app-post_"

if [ ${PKG_REQ_VARIABLE}} == "~" ]
then
	PKG_REQ_VARIABLE="${PKG_YML_FILEPATH}"
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

export CLR_BLACK='\e[0;30m'
export CLR_RED='\e[0;31m'
export CLR_GREEN='\e[0;32m'
export CLR_YELLOW='\e[0;33m'
export CLR_BLUE='\e[0;34m'
export CLR_PURPLE='\e[0;35m'
export CLR_CYAN='\e[0;36m'
export CLR_WHITE='\e[0;37m'

export CLR_L_BLACK='\e[0;90m'
export CLR_L_RED='\e[0;91m'
export CLR_L_GREEN='\e[0;92m'
export CLR_L_YELLOW='\e[0;93m'
export CLR_L_BLUE='\e[0;94m'
export CLR_L_PURPLE='\e[0;95m'
export CLR_L_CYAN='\e[0;96m'
export CLR_L_WHITE='\e[0;97m'

export CLR_B_BLACK='\e[1;30m'
export CLR_B_RED='\e[1;31m'
export CLR_B_GREEN='\e[1;32m'
export CLR_B_YELLOW='\e[1;33m'
export CLR_B_BLUE='\e[1;34m'
export CLR_B_PURPLE='\e[1;35m'
export CLR_B_CYAN='\e[1;36m'
export CLR_B_WHITE='\e[1;97m'

export CLR_U_BLACK='\e[4;30m'
export CLR_U_RED='\e[4;31m'
export CLR_U_GREEN='\e[4;32m'
export CLR_U_YELLOW='\e[4;33m'
export CLR_U_BLUE='\e[4;34m'
export CLR_U_PURPLE='\e[4;35m'
export CLR_U_CYAN='\e[4;36m'
export CLR_U_WHITE='\e[4;97m'

export CLR_BG_BLACK='\e[40m'
export CLR_BG_RED='\e[41m'
export CLR_BG_GREEN='\e[42m'
export CLR_BG_YELLOW='\e[43m'
export CLR_BG_BLUE='\e[44m'
export CLR_BG_PURPLE='\e[45m'
export CLR_BG_CYAN='\e[46m'
export CLR_BG_WHITE='\e[47m'

export CLR_RST='\e[0m'

export CLR_TXT_D="${CLR_WHITE}"
export CLR_PRE_D="${CLR_L_WHITE}"
export CLR_HDR_D="${CLR_WHITE}"
export CLR_TXT=""
export CLR_PRE=""
export CLR_HDR=""
export OUT_NEW_LINE=true
export OUT_PRE_LINE=true
export OUT_MAX_CHAR=100
export OUT_SPACE_F=1
export OUT_SPACE_N=1

# EOF #
