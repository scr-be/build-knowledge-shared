#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

APP_CMD_LOG="/tmp/script-app.out"

if [[ ! -x ${SCRIPT_APP} ]]
then
    outWarning \
        "Console command ${SCRIPT_APP} not found."
else
    for cmd in "${APP_CMDS[@]}"
    do
        opExec \
            "${BIN_PHP} $SCRIPT_APP $cmd"

        CMD_FAIL=false && touch "${APP_CMD_LOG}"

        ${BIN_PHP} $SCRIPT_APP $cmd &>> "${APP_CMD_LOG}" || CMD_FAIL=true

        if [[ ${CMD_FAIL} == true ]]
        then
            outWarning \
                "Command returned non-zero exit code. Output of command:"

            cat "${APP_CMD_LOG}" && newLine
        fi

        rm -fr "${APP_CMD_LOG}"
    done
fi

for cmd in "${APP_EXT_CMDS[@]}"
do
    opExec \
        "${cmd}"

    CMD_FAIL=false && touch "${APP_CMD_LOG}"

    ${BIN_PHP} $SCRIPT_APP $cmd &>> "${cmd}" || CMD_FAIL=true

    if [[ ${CMD_FAIL} == true ]]
    then
        outWarning \
            "Command returned non-zero exit code. Output of command:"

        cat "${APP_CMD_LOG}" && newLine
    fi

    rm -fr "${APP_CMD_LOG}"
done

APP_CMDS=()
APP_EXT_CMDS=()

# EOF #
