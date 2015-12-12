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

opStart "Install \"${PHP_MODULE}\" extension."

RUN_SCRIPT_PATH="${INC_MODS_PATH}/php-$(getMajorPHPVersion)/${INC_MODS_FILE}${e}.bash"

if [ ! -e ${RUN_SCRIPT_PATH} ]; then
    outError "Could not find valid script \"${RUN_SCRIPT_PATH}\"."
fi

if [ $(isExtensionEnabled ${PHP_MODULE}) == "true" ]
then
    outInfo "Removing previous installation."
    opExec "${CMD_PRE}pecl uninstall ${PHP_MODULE} &>> /dev/null"
    ${CMD_PRE} pecl uninstall ${PHP_MODULE} &>> /dev/null || outWarning \
        "Failed to remove previous install but blindly attempting to continue anyway."
fi

opExec "bash ${RUN_SCRIPT_PATH}"
MOD_RESULT=0
bash ${RUN_SCRIPT_PATH} &>> /dev/null || MOD_RESULT="$?"

if [[ ${MOD_RESULT} == 0 ]] && [[ $(isExtensionEnabled ${PHP_MODULE}) != "true" ]]; then
    if [ ${BIN_PHPENV} ]
    then
        opExec "${BIN_PHPENV} config-add ${INC_INCS_PATH}/${INC_INCS_FILE}use-${PHP_MODULE}.ini"
        ${BIN_PHPENV} config-add "${INC_INCS_PATH}/${INC_INCS_FILE}use-${PHP_MODULE}.ini" &>> /dev/null || outWarning \
            "Could not add ${INC_INCS_FILE}use-${PHP_MODULE}.ini to PHP config."
        ${BIN_PHPENV} rehash
    else
        outInfo \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${PHP_MODULE}.so\" to enable the extension."
    fi
fi

if [[ ${MOD_RESULT} == 0 ]]
then
    opDone \
        "Install \"${PHP_MODULE}\" extension."
else
    opFail \
        "Install \"${PHP_MODULE}\" extension."
fi

# EOF #
