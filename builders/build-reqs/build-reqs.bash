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
    "Running Action" "${ACTION}" \
    "OS Support"     "YES (${DISTRIB_ID} ${DISTRIB_RELEASE}, ${DISTRIB_CODENAME})"
    "Travis CI"      "$(getYesOrNoForCompare ${env_location} ci)" \
    "Sudo Enabled"   "$(getYesOrNoForCompare ${CMD_PRE} "sudo ")" \
    "Loaded Config"  "${SCRIPT_CALLER_ROOT}/${VAR_ENV_PKG_PATH}" \
    \
    ":Handlers" \
    "PHP Configurations"    "${INC_INCS_PATH}" \
    "PHP Extensions"        "${INC_MODS_PATH}" \
    "External Dependencies" "${INC_SYSR_PATH}" \
    "Application Commands"  "${INC_SYMF_PATH}" \
    \
    ":PHP" \
    "Major Release"           "$(getMajorPHPVersion).x Series" \
    "API Supported"           "YES (${VER_PHPAPI_ENG}/${VER_PHPAPI_MOD})" \
    "Environment Supported"   "$(getYesOrNoForCompare ${VER_PHP_ON_UNSU:-x} "x") (PHP    v${VER_PHP})" \
    "PHPEnv Installed"        "$(echo ${env_with_phpenv} | tr '[:lower:]' '[:upper:]') ${env_ver_phpenv}" \
    \
    ":Package Config" \
    "PHP Extensions"       "${scr_pkg_phpexts_req:-NONE}" \
    "INI Filess"           "${scr_pkg_phpincs_req:-NONE}" \
    "System Requirements"  "${scr_pkg_syspkgs_req:-NONE}" \
    "Coverage Services"    "${scr_pkg_ci_send_req:-NONE}" \
    "Script UP Operations" "${scr_pkg_symf_up_req:-NONE}" \
    "Script DN Operations" "${scr_pkg_symf_dn_req:-NONE}" \
    "Script Bin Path"      "${scr_pkg_symfcmd_bin:-NONE}" \
    \
    ":Logging/Working Paths" \
    "General (L)"        "${LOG_GNRL:-NONE}" \
    "General (W)"        "${BLD_GNRL:-NONE}" \
    "Pecl Extension (L)" "${LOG_PECL:-NONE}" \
    "Pecl Extension (W)" "${BLD_PECL:-NONE}" \
    "Enviornment (L)"    "${LOG_SYSD:-NONE}" \
    "Enviornment (W)"    "${BLD_SYSD:-NONE}" \
    \
    ":Binary Paths" \
    "curl"   "${BIN_CURL:-NONE}" \
    "git"    "${BIN_GIT:-NONE}" \
    "tar"    "${BIN_TAR:-NONE}" \
    "make"   "${BIN_MAKE:-NONE}" \
    "php"    "${BIN_PHP:-NONE}" \
    "phpenv" "${BIN_PHPENV:-NONE}" \
    "phpize" "${BIN_PHPIZE:-NONE}" \
    "pecl"   "${BIN_PECL:-NONE}"
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
