#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

if [[ ! -x ${APP_MAKE_CLI} ]]
then
    outWarning "App CLI command ${APP_MAKE_CLI} not found."
else
    for c in "${APP_MAKE_CMDS_PHP[@]}"
    do
        APP_MAKE_RET=false
        APP_MAKE_LOG=$(getReadyTempFilePath ${LOG_SYMF}${c//[^A-Za-z0-9._-]/_}.log)
        ALL_LOGS+=("${APP_MAKE_LOG}")

        opExec "${BIN_PHP} ${APP_MAKE_CLI} ${c}"

        "${BIN_PHP}" "${APP_MAKE_CLI}" ${c} &>> "${APP_MAKE_LOG}" || APP_MAKE_RET=true

        if [[ ${APP_MAKE_RET} == true ]]
        then
            opFailLogOutput "${APP_MAKE_LOG}" "${APP_MAKE_CLI/${DIR_CWD}\//} ${c}"
        fi
    done
fi

for c in "${APP_MAKE_CMDS_EXT[@]}"
do
    opExec "${c}"

    APP_MAKE_RET=false
    APP_MAKE_LOG=$(getReadyTempFilePath "${LOG_SYSD}${c//[^A-Za-z0-9._-]/_}.log")
    ALL_LOGS+=("${APP_MAKE_LOG}")

    "${BIN_PHP}" "${c}" &>> "${APP_MAKE_LOG}" || APP_MAKE_RET=true

    if [[ ${APP_MAKE_RET} == true ]]
    then
        opFailLogOutput "${APP_MAKE_LOG}" "${APP_MAKE_CLI/${DIR_CWD}\//} ${c}"
    fi
done

APP_MAKE_CMDS_PHP=()
APP_MAKE_CMDS_EXT=()

# EOF #
