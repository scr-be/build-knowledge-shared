#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

SCRIPT_SELF_PATH="${0}"
SCRIPT_SELF_BASE="$(basename ${0})"
SCRIPT_SELF_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z ${PHP_MODULE} ]
then
    PHP_MODULE="$(basename ${SCRIPT_SELF_BASE:14} .bash)"
fi

type outLines &>> /dev/null || . ${SCRIPT_SELF_REAL}/../_common/bash-inc_all.bash

outInfo "Installing PHP extension \"${PHP_MODULE}\""

RUN_SCRIPT_PATH="${INC_MODS_PATH}/php-$(getMajorPHPVersion)/${INC_MODS_FILE}${e}.bash"

if [ ! -e ${RUN_SCRIPT_PATH} ]; then
    outErrorAndExit "Could not find valid script ${RUN_SCRIPT_PATH}"
fi

if [ $(isExtensionEnabled ${PHP_MODULE}) == "true" ]
then
    outNotice "Removing previous version of extension..."
    ${CMD_PRE} pecl uninstall ${PHP_MODULE} &>> /dev/null || outNotice \
        "Failed to remove previous version...attempting install."
fi

outInfo "Running ${RUN_SCRIPT_PATH}"
MOD_RESULT=0
bash ${RUN_SCRIPT_PATH} &>> /dev/null || MOD_RESULT="$?"

if [[ ${MOD_RESULT} == 0 ]] && [[ $(isExtensionEnabled ${PHP_MODULE}) != "true" ]]; then
    if [ ${BIN_PHPENV} ]
    then
        ${BIN_PHPENV} config-add "${INC_INCS_PATH}/${INC_INCS_FILE}use-${PHP_MODULE}.ini" &>> /dev/null || outError \
            "Could not add ${INC_INCS_FILE}use-${PHP_MODULE}.ini to PHP config."
        outSuccess "Adding PHP config ${INC_INCS_PATH}/${INC_INCS_FILE}use-${PHP_MODULE}.ini"
        ${BIN_PHPENV} rehash
    else
        outError \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${PHP_MODULE}.so\" to enable the extension."
    fi
fi

if [[ ${MOD_RESULT} == 0 ]]
then
    outSuccess \
        "Completed installation of \"${PHP_MODULE}\""
else
    outError \
        "Could not install \"${PHP_MODULE}\""
fi

# EOF #
