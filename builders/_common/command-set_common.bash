#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

opStart "Running \"${RT_MODE^^}\" external operations."

RT_INDEX=-1

for c in "${RT_INCS[@]}"
do
    if [[ ${RT_MODE_APPEND} == false ]]
    then
        RT_ACT="${c}"
    else
        RT_ACT="${RT_MODE}-${c}"
    fi

    RT_INDEX=$(((${RT_INDEX} + 1)))

    RT_COMMANDS_RET_SINGLE=0
    RT_COMMANDS_RET=0
    RT_COMMANDS_ACT=false
    RT_FILEPATH_INC="$(readlink -m ${RT_PATH}/${RT_FILE}${RT_ACT}.bash)"
    RT_FILEPATH_LOG=$(getReadyTempFilePath ${LOG_GEN}${RT_ACT//[^A-Za-z0-9._-]/_}.log)

    LOG_ALL+=("${RT_FILEPATH_LOG}")

    opSource "${RT_FILEPATH_INC}"

    . ${RT_FILEPATH_INC}

    if [[ ${RT_COMMANDS_ACT} == false ]] || [[ ${#RT_COMMANDS_ACT[@]} == 0 ]]
    then
        outInfo "No operation commands defined in ${RT_FILEPATH_INC}"
        continue
    fi

    for command in "${RT_COMMANDS_ACT[@]}"
    do
        opExec "${command}"
        ${command} &>> ${RT_FILEPATH_LOG} || RT_COMMANDS_RET=1

        if [[ ${RT_COMMANDS_RET_SINGLE} == 0 ]] && [[ ! ${RT_COMMANDS_ACT_FB[$RT_INDEX]} ]]
        then
            continue
        fi

        outWarning "Using fallback command due to previous failure."

        RT_COMMANDS_RET=0
        command_fallback=${RT_COMMANDS_ACT_FB[$RT_INDEX]}

        opExec "${command_fallback}"
        ${command_fallback} &>> ${RT_FILEPATH_LOG} || RT_COMMANDS_RET=1
    done

    if [[ ${RT_COMMANDS_RET} != 0 ]]
    then
        opFailLogOutput "${RT_FILEPATH_LOG}" "${RT_MODE}:${c}"
    fi
done

opDone "Running \"${RT_MODE^^}\" external operations."

export RT_MODE_APPEND=false
export RT_MODE=""
export RT_INCS=()
export RT_PATH=""
export RT_FILE=""
export RT_COMMANDS_RET=0
export RT_COMMANDS_ACT=()
export RT_COMMANDS_ACT_FB=()

# EOF #
