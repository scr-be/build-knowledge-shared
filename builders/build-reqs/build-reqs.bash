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
    "OS Platform"    "${DISTRIB_ID} ${DISTRIB_RELEASE} (${DISTRIB_CODENAME})" \
    "OS Supported"   "YES"
    "Travis CI"      "$(getYesOrNoForCompare ${env_location} ci)" \
    "Using Sudo"     "$(getYesOrNoForCompare ${CMD_PRE} "sudo ")" \
    "Current Action" "${ACTION}" \
    \
    ":PHP" \
    "Version"             "$(getMajorPHPVersion).x Series" \
    "Version String"      "${VER_PHP}" \
    "Version Supported"   "$(getYesOrNoForCompare ${VER_PHP_ON_UNSU:-x} "x")" \
    "Executable (php)"    "${BIN_PHP}" \
    "Executable (phpenv)" "${BIN_PHPIZE}" \
    "Using PhpEnv"        "$(echo ${env_with_phpenv} | tr '[:lower:]' '[:upper:]')" \
    \
    ":Builder Paths" \
    "Loaded Builder File"    "${SCRIPT_CALLER_RPATH}/${SCRIPT_CALLER_NAME}" \
    "Loaded Config File"     "${SCRIPT_CALLER_ROOT}/${VAR_ENV_SCRIBE_PATH}" \
    "Extension Installers"   "${INC_MODS_PATH}" \
    "System Req. Installers" "${INC_SYSR_PATH}" \
    "Config Includes"        "${INC_INCS_PATH}" \
    \
    ":Builder Config" \
    "Extension(s)"           "${scr_pkg_phpexts_req:-NONE}" \
    "INI Files(s)"           "${scr_pkg_phpincs_req:-NONE}" \
    "System Requirement(s)"  "${scr_pkg_syspkgs_req:-NONE}" \
    "Configured CI Send(s)"  "${scr_pkg_ci_send_req:-NONE}"
)

outListing "${listing[@]}"

sleep 2

if [ ! ${VER_PHP_ON_5} ] && [ ! ${VER_PHP_ON_7} ]
then
    outError \
        "Unsupported PHP version for auto-builds. Found ${VER_PHP}."    
fi

STATE_FILE_INCLUDE="${SCRIPT_CALLER_RPATH}/$(basename ${SCRIPT_CALLER_NAME} .bash)_${ACTION}.bash"

if [[ ! -f ${STATE_FILE_INCLUDE} ]]
then
    outWarning "Operation file ${STATE_FILE_INCLUDE} does not exist."
else
    opExec \
        "source ${STATE_FILE_INCLUDE}"

    . ${STATE_FILE_INCLUDE}
fi

outComplete \
    "All operations for \"${ACTION}\" routine completed without error."

exit 0

# EOF #
