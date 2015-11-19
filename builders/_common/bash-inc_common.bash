#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

. /etc/lsb-release || outErrorAndExit \
    "Automatic builds only supported on Ubuntu at this time. Could not find lsb_release file."

[[ ${DISTRIB_ID} != ${VER_ENV_DIST} ]] && outErrorAndExit \
    "Automatic builds only supported on Ubuntu at this time. Could not find valid \$DISTRIB_ID."

valueInList "${DISTRIB_CODENAME:-x}" "${VER_ENV_SUPPORT}" &>> /dev/null || outErrorAndExit \
    "Automatic builds only supported on Ubuntu versions (${VER_ENV_SUPPORT}) at this time. Found" \
    "version ${DISTRIB_CODENAME}."

[[ "${BIN_PHP:-x}" == "x" ]] && outErrorAndExit  \
    "Could not find a valid PHP binary within your configured path: \"${PATH}\"."

if [ "${TRAVIS:-x}" == "x" ]
then
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        CMD_PRE="sudo "
        env_location="local" && env_with_phpenv="no"
    else
        env_location="local" && env_with_phpenv="yes"
    fi
else
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        env_location="travis" && env_with_phpenv="no"
    else
        env_location="travis" && env_with_phpenv="yes"
    fi
fi

if [ "${VAR_ENV_SCRIBE_PATH:-x}" == "x" ]
then
    outErrorAndExit \
        "The 'scribe_packaged' enviornment variable must be defined!"
fi

if [ "${VAR_ENV_SCRIBE_PATH}" == "true" ]
then
    VAR_ENV_SCRIBE_PATH="${VAR_ENV_SCRIBE_PATH_DEFAULT}" && outInfo \
        "Attempting to use default package config location of ${VAR_ENV_SCRIBE_PATH_DEFAULT}."
fi

if [ ! -f "${SCRIPT_CALLER_ROOT}/${VAR_ENV_SCRIBE_PATH}" ]; then
    outErrorAndExit \
        "Unable to find the package configuration. This must be defined and set to the" \
        "location of your configuration YAML, or simply true to use the default path."
fi

eval $(parseYaml "${SCRIPT_CALLER_ROOT}/${VAR_ENV_SCRIBE_PATH}" "${VAR_ENV_SCRIBE_PREFIX}")

for item in $(commaToSpaceSeparated ${VAR_ENV_SCRIBE_CHECK})
do
    if [ ${item:-x} == "x" ] || [ ${!item:-x} == "x" ] || [ ${!item:-x} == "~" ]
    then
        assignIndirect "${item}" ""
    fi
done

# EOF #
