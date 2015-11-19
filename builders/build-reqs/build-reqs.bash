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

type outLines &>> /dev/null || . ${SCRIPT_CALLER_RPATH}/../_common/bash-inc_all.bash

if [ ! -f "/etc/lsb-release" ]
then
    outErrorAndExit \
        "Automatic builds only supported on ubuntu at this time. Could not find lsb_release file."
else
    . /etc/lsb-release
fi

if [ "${BIN_PHP:-x}" == "x" ]
then
    outErrorAndExit  \
        "Could not find a valid PHP binary within your configured path: \"${PATH}\"." \
        "You will need to install it before continuing."
fi

if [ "${TRAVIS:-x}" == "x" ]
then
    env_location="local"
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        CMD_PRE="sudo "
        env_with_phpenv="no"
    else
        env_with_phpenv="yes"
    fi
else
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        env_location="travis" && env_with_phpenv="no"
    else
        env_location="travis" && env_with_phpenv="yes"
    fi
fi

if [ "${scribe_packaged:-x}" == "x" ] || [ ! -f "${SCRIPT_CALLER_ROOT}/${scribe_packaged}" ]; then
    outErrorAndExit \
        "The 'scribe_packaged' enviornment variable must be defined and set to the" \
        "location of your configuration YAML."
fi

eval $(parseYaml "${SCRIPT_CALLER_ROOT}/${scribe_packaged}" "scr_pkg_")

outListing \
    "Ver_PHP_Full" "${VER_PHP}" \
    "Ver_PHP_Main" "$(getMajorPHPVersion)" \
    "Ver_Has_Supp" "$(if [ ${VER_PHP_ON_5} ] || [ ${VER_PHP_ON_7} ]; then echo "yes"; else echo "no"; fi)" \
    "Bin_PHP_Path" "${BIN_PHP}" \
    "Env_PHP_Path" "${env_with_phpenv}" \
    "Env_Location" "${env_location}" \
    "Env_Platform" "${DISTRIB_CODENAME}" \
    "Env_Requires" "${scr_pkg_phpexts_req:-none}" \
    "Scr_FilePath" "${SCRIPT_CALLER_SPATH}"

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
