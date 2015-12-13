#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

set -e

if [[ ${BUILDER_DEBUG} == "true" ]]
then
    set -x
fi

readonly SCRIPT_CALLER_MAIN=true
readonly SCRIPT_CALLER_SPATH="${0}"
readonly SCRIPT_CALLER_RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}" 2> /dev/null)" && pwd)"
readonly SCRIPT_CALLER_NAME="$(basename ${SCRIPT_CALLER_SPATH} 2> /dev/null)"
readonly SCRIPT_CALLER_ROOT="$(pwd)"

export SCRIPT_CALLER_MAIN
export SCRIPT_CALLER_SPATH
export SCRIPT_CALLER_RPATH
export SCRIPT_CALLER_NAME
export SCRIPT_CALLER_ROOT

type outLines &>> /dev/null || . ${SCRIPT_CALLER_RPATH}/../_common/bash-inc_all.bash

listing=(
    ":General" \
    "Enviornment:OS"       "${DISTRIB_ID} ${DISTRIB_RELEASE}"
    "Enviornment:Action"   "${ACTION^^}" \
    "Enviornment:Location" "${env_location^^}" \
    "Enviornment:Travis"   "$(getYesOrNoForCompare ${env_location} ci)" \
    #"Sudo"                "$(getYesOrNoForCompare ${CMD_PRE} "sudo ")" \
    "Enviornment:Config"   "${SCRIPT_CALLER_ROOT}/${VAR_ENV_PKG_PATH}" \
    \
    ":PHP" \
    "Release"               "$(getMajorPHPVersion).x Series" \
    "Supported:API"         "YES (${VER_PHPAPI_ENG}/${VER_PHPAPI_MOD})" \
    "Supported:Environment" "$(getYesOrNoForCompare ${VER_PHP_ON_UNSU:-x} "x") (PHP    v${VER_PHP})" \
    "Supported:PHPEnv"      "$(echo ${env_with_phpenv} | tr '[:lower:]' '[:upper:]') ${env_ver_phpenv}" \
   #\
   #":Handlers" \
   #"Requires:Extentions"  "${INC_MODS_PATH}" \
   #"Requires:Config"      "${INC_INCS_PATH}" \
   #"Required:Enviornment" "${INC_SYSR_PATH}" \
   #"Application:Reports"  "${INC_EOPT_PATH}" \
   #"Application:Console"  "${INC_SYMF_PATH}" \
   #\
   #":Working/Logging Paths" \
   #"Work:General"        "${BLD_GNRL:-NONE}" \
   #"Work:Pecl Extension" "${BLD_PECL:-NONE}" \
   #"Work:Enviornment"    "${BLD_SYSD:-NONE}" \
   #"Logs:General"        "${LOG_GNRL:-NONE}" \
   #"Logs:Pecl Extension" "${LOG_PECL:-NONE}" \
   #"Logs:Enviornment"    "${LOG_SYSD:-NONE}" \
   #\
    ":Repository Package Configuation" \
    "Requires:Extentions"  "${scr_pkg_php_r_exts:-NONE}" \
    "Requires:Config"      "${scr_pkg_php_r_cfgs:-NONE}" \
    "Required:Enviornment" "${scr_pkg_env_r_deps:-NONE}" \
    "Operations:DN"        "${scr_pkg_app_up_ops:-NONE}" \
    "Operations:UP"        "${scr_pkg_app_dn_ops:-NONE}" \
    "Application:Reports"  "${scr_pkg_env_ci_ops:-NONE}" \
    "Application:Console"  "${scr_pkg_app_binary:-NONE}"
   #\
   #":Binary Paths" \
   #"curl"   "${BIN_CURL:-NONE}" \
   #"git"    "${BIN_GIT:-NONE}" \
   #"tar"    "${BIN_TAR:-NONE}" \
   #"make"   "${BIN_MAKE:-NONE}" \
   #"php"    "${BIN_PHP:-NONE}" \
   #"phpenv" "${BIN_PHPENV:-NONE}" \
   #"phpize" "${BIN_PHPIZE:-NONE}" \
   #"pecl"   "${BIN_PECL:-NONE}"
)

outListing "${listing[@]}"

sleep 1

if [ ! ${VER_PHP_ON_5} ] && [ ! ${VER_PHP_ON_7} ]
then
    outError "Unsupported PHP version for auto-builds. Found ${VER_PHP}."    
fi

STATE_FILE_INCLUDE="${SCRIPT_CALLER_RPATH}/$(basename ${SCRIPT_CALLER_NAME} .bash)_${ACTION}.bash"

if [[ ! -f ${STATE_FILE_INCLUDE} ]]
then
    outWarning "Operation file ${STATE_FILE_INCLUDE} does not exist."
else
    opSource "${STATE_FILE_INCLUDE}"

    . ${STATE_FILE_INCLUDE}
fi

outComplete \
    "All operations for \"${ACTION}\" routine completed without error."

exit 0

# EOF #
