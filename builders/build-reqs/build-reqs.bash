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
    ":Runtime Enviornment" \
    "Enviornment:OS"       "${DISTRIB_ID} ${DISTRIB_RELEASE}"
    "Enviornment:Action"   "${ACTION^^}" \
    "Enviornment:Location" "${env_location^^}" \
    "Enviornment:Travis"   "$(getYesOrNoForCompare ${env_location} ci)" \
    "Enviornment:Config"   "${SCRIPT_CALLER_ROOT}/${PKG_ENV_VARIABLE}" \
    \
    ":PHP/Engine Information" \
    "Release:PHP"           "$(getMajorPHPVersion).x Series" \
    "Supported:PHP:Version" "$(getYesOrNoForCompare ${VER_PHP_ON_UNSU:-x} "x") (PHP     v${VER_PHP})" \
    "Supported:PHP:Engine"  "YES (Engine  ${VER_PHPAPI_ENG}/${VER_PHPAPI_MOD})" \
    "Supported:PHP:Xdebug"  "YES (Xdebug  v${VER_PHP_XDEBUG})" \
    "Supported:PHP:Opcache" "YES (Opcache v${VER_PHP_OPCACHE})" \
    "Installed:PHPEnv"      "$(echo ${env_with_phpenv} | tr '[:lower:]' '[:upper:]') ${env_ver_phpenv}" \
    "Installed:HHVM"        "$(echo ${env_with_hhvm} | tr '[:lower:]' '[:upper:]') ${env_ver_hhvm}" \
    \
    ":Package Configuration" \
    "Environment:Make"    "${scr_pkg_env_make:-NONE}" \
    "Environment:Prepare" "${scr_pkg_env_prep:-NONE}" \
    "Environment:Postrun" "${scr_pkg_env_post:-NONE}" \
    "PHP:Extensions"      "${scr_pkg_php_exts:-NONE}" \
    "PHP:Configuration"   "${scr_pkg_php_conf:-NONE}" \
    "Application:Prepare" "${scr_pkg_app_prep:-NONE}" \
    "Application:Postrun" "${scr_pkg_app_post:-NONE}" \
    "Application:Console" "${scr_pkg_app_path:-NONE}"
#    \
#    ":Handlers" \
#    "Requires:Extentions"  "${INC_PHP_EXTS_PATH}" \
#    "Requires:Config"      "${INC_PHP_CONF_PATH}" \
#    "Required:Enviornment" "${INC_ENV_MAKE_PATH}" \
#    "Application:Reports"  "${INC_ENV_POST_PATH}" \
#    "Application:Console"  "${INC_APP_PREP_PATH}" \
#    \
#    ":Build and Log Paths" \
#    "Build:General"     "${BLD_GEN:-NONE}" \
#    "Build:Extensions"  "${BLD_EXT:-NONE}" \
#    "Build:Enviornment" "${BLD_ENV:-NONE}" \
#    "Build:Application" "${BLD_APP:-NONE}" \
#    "Logs:General"      "${LOG_GEN:-NONE}" \
#    "Logs:Extensions"   "${LOG_EXT:-NONE}" \
#    "Logs:Enviornment"  "${LOG_ENV:-NONE}" \
#    "Logs:Application"  "${LOG_APP:-NONE}"
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
