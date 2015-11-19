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
PHP_MODULE="$(basename ${SCRIPT_SELF_BASE:14} .bash)"

type outLines &>> /dev/null || . ${SCRIPT_SELF_REAL}/../_common/bash-inc_all.bash

outInfo "Attempting to install module: ${PHP_MODULE}"

RUN_SCRIPT_PATH="${SCRIPT_SELF_REAL}/php-$(getMajorPHPVersion)/$(basename ${SCRIPT_SELF_PATH})"

if [ ! -e ${RUN_SCRIPT_PATH} ]; then
    outErrorAndExit "Could not find valid script ${RUN_SCRIPT_PATH}"
fi

if [ $(isExtensionEnabled ${PHP_MODULE}) ]
then
    outInfo "Removing previous version of ${PHP_MODULE}"
    ${CMD_PRE} pecl uninstall ${PHP_MODULE} &>> /dev/null
fi

outInfo "Running installer script ${RUN_SCRIPT_PATH}"
bash ${RUN_SCRIPT_PATH}

if [[ $(isExtensionEnabled ${PHP_MODULE}) == "true" ]]; then
    outSuccess "Extension already loaded for ${PHP_MODULE}. Skipping ini configuration."
else
    if [ ${BIN_PHPENV} ]
    then
        outInfo "Added php-incs_set-${PHP_MODULE}.ini to phpenv config."
        ${BIN_PHPENV} config-add "${SCRIPT_SELF_REAL}/../_php-incs/php-incs_use-${PHP_MODULE}.ini" &>> /dev/null || outError \
            "Could not add ${PHP_MODULE} to PHP config ini."
        ${BIN_PHPENV} rehash
    else
        outError \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${PHP_MODULE}.so\" to enable the extension."
    fi
fi

# EOF #
