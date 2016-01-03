#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

if [[ ${RT_MODE_DESC} == false ]]
then
    RT_MODE_DESC="${RT_MODE}"
fi

opStart "Running \"${RT_MODE_DESC^^}\""

RT_INDEX=-1
RT_COUNT=0
RT_ENV_MAKE_ENTER_DIR=false

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
    RT_FILEPATH_INC="$(readlink -m ${RT_PATH}/${RT_FILE}${RT_ACT}.bash)"
    RT_FILEPATH_LOG=$(getReadyTempFilePath ${LOG_GEN}${RT_ACT//[^A-Za-z0-9._-]/_}.log)

    LOG_ALL+=("${RT_FILEPATH_LOG}")

    if [[ ${RT_COMMANDS_INC} != false ]]
    then
        RT_COMMANDS_ACT=false

        opSource "${RT_FILEPATH_INC}"

        . ${RT_FILEPATH_INC}
    fi

    if [[ ${RT_COMMANDS_ACT} == false ]] || [[ ${#RT_COMMANDS_ACT[@]} == 0 ]]
    then
        outWarning "No operation commands defined in ${RT_FILEPATH_INC}"
        continue
    fi

    MOD_ENV_MAKE_BLD="${BLD_EXT}/$(date +%s.%N)"
    MOD_ENV_MAKE_BLD=$(getReadyTempPath ${MOD_ENV_MAKE_BLD})

    if [[ ${RT_ENV_MAKE_ENTER_DIR} != false ]]
    then
        opExec "cd ${MOD_ENV_MAKE_BLD}"
        cd ${MOD_ENV_MAKE_BLD}
    fi

    for command in "${RT_COMMANDS_ACT[@]}"
    do
        RT_COMMANDS_RET_SINGLE=0

        opExec "${command}"
        ${command} &>> ${RT_FILEPATH_LOG} || RT_COMMANDS_RET_SINGLE=1

        RT_COUNT=$(((${RT_COUNT} + 1)))

        if [[ ${RT_COMMANDS_RET_SINGLE} == 0 ]] || [[ ${RT_COMMANDS_ACT_FB[$RT_INDEX]} == "" ]]
        then
            RT_COMMANDS_RET=${RT_COMMANDS_RET_SINGLE}
            continue
        fi

        outWarning "Attempting fallback command due to previous command failure."

        RT_COMMANDS_RET_SINGLE=0
        command_fallback=${RT_COMMANDS_ACT_FB[$RT_INDEX]}

        opExec "${command_fallback}"
        ${command_fallback} &>> ${RT_FILEPATH_LOG} || RT_COMMANDS_RET_SINGLE=1

        if [[ ${RT_COMMANDS_RET_SINGLE} == 1 ]]
        then
            RT_COMMANDS_RET=${RT_COMMANDS_RET_SINGLE}
        fi
    done

    if [[ ${RT_COMMANDS_RET} != 0 ]]
    then
        opFailLogOutput "${RT_FILEPATH_LOG}" "${RT_MODE}:${c}"
    fi
done

if [[ ${RT_COUNT} == 0 ]]
then
    outWarning "No commands executed for \"${RT_MODE_DESC^^}\""
fi

opDone "Running \"${RT_MODE_DESC^^}\""

export RT_MODE_APPEND=false
export RT_MODE=""
export RT_MODE_DESC=false
export RT_INCS=()
export RT_PATH=""
export RT_FILE=""
export RT_COMMANDS_RET=0
export RT_COMMANDS_ACT=()
export RT_COMMANDS_ACT_FB=()
export RT_COMMANDS_INC=true

# EOF #
