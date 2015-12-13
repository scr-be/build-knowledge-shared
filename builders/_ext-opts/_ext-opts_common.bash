#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

opStart "Running \"${INC_EOPT_RT_MODE^^}\" external operations."

for c in "${INC_EOPT_RT_INCS[@]}"
do
    INC_EOPT_RT_RET=0
    INC_EOPT_RT_ACT="${INC_EOPT_RT_MODE}-${c}"
    INC_EOPT_RT_INC="$(readlink -m ${INC_EOPT_PATH}/${INC_EOPT_FILE}${INC_EOPT_RT_ACT}.bash)"
    INC_EOPT_LOG=$(getReadyTempFilePath ${LOG_GNRL}${INC_EOPT_RT_ACT//[^A-Za-z0-9._-]/_}.log)
    ALL_LOGS+=("${INC_EOPT_LOG}")
    INC_EOPT_RT_CMDS=false

    if [[ ${INC_EOPT_RT_INC} == "" ]] || [[ ! -f ${INC_EOPT_RT_INC} ]]
    then
        outInfo "Skipping ${INC_EOPT_RT_INC} as it does not exist."
        continue
    fi

    opSource "${INC_EOPT_RT_INC}"
    . ${INC_EOPT_RT_INC}

    if [[ ${INC_EOPT_RT_CMDS} == false ]] || [[ ${#INC_EOPT_RT_CMDS[@]} == 0 ]]
    then
        outInfo "No operation commands defined for in ${INC_EOPT_RT_INC}"
        continue
    fi

    for command in "${INC_EOPT_RT_CMDS[@]}"
    do
        opExec "${command}"
        ${command} &>> ${INC_EOPT_LOG} || INC_EOPT_RT_RET=1
    done

    if [[ ${INC_EOPT_RT_RET} != 0 ]]
    then
        opFailLogOutput "${INC_EOPT_LOG}" "${INC_EOPT_RT_MODE}:${c}"
    fi
done

opDone "Running \"${INC_EOPT_RT_MODE^^}\" external operations."

INC_EOPT_RT_INCS=()

# EOF #
