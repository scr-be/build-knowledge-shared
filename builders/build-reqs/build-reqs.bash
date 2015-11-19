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

readonly SCRIPT_CALLER_SPATH="${0}"
readonly SCRIPT_CALLER_RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}" 2> /dev/null)" && pwd)"
readonly SCRIPT_CALLER_NAME="$(basename ${SCRIPT_CALLER_SPATH} 2> /dev/null)"
readonly SCRIPT_CALLER_ROOT="$(pwd)"

export SCRIPT_CALLER_SPATH
export SCRIPT_CALLER_RPATH
export SCRIPT_CALLER_NAME
export SCRIPT_CALLER_ROOT

type outLines &>> /dev/null || . ${SCRIPT_CALLER_RPATH}/../_common/bash-inc_all.bash

outListing \
    "Ver_PHP_Full" "${VER_PHP}" \
    "Ver_PHP_Main" "$(getMajorPHPVersion)" \
    "Ver_Has_Supp" "$(if [ ${VER_PHP_ON_5} ] || [ ${VER_PHP_ON_7} ]; then echo "yes"; else echo "no"; fi)" \
    "Bin_PHP_Path" "${BIN_PHP}" \
    "Env_PHP_Path" "${env_with_phpenv}" \
    "Env_Location" "${env_location}" \
    "Env_Platform" "${DISTRIB_CODENAME}" \
    "Env_Pkg_File" "${scribe_packaged}" \
    "Env_Requires" "${scr_pkg_phpexts_req:-none}" \
    "INI_Requires" "${scr_pkg_phpincs_req:-none}" \
    "Sys_Requires" "${scr_pkg_syspkgs_req:-none}" \
    "Scr_FilePath" "${SCRIPT_CALLER_SPATH}"

sleep 4

STATE_FILE_INCLUDE="${SCRIPT_CALLER_RPATH}/$(basename ${SCRIPT_CALLER_NAME} .bash)"

if [ "${1}" == "up" ]; then
    outInfo "Running UP"
  . ${STATE_FILE_INCLUDE}_up.bash
else
    outInfo "Running DOWN"
  . ${STATE_FILE_INCLUDE}_down.bash
fi

outSuccess "Complete."

# EOF #
