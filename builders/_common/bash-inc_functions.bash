#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

function newLine()
{
    echo -en "\n"
}

function outLines()
{
    local p="${1:---}"

    shift

    local len=0
    local ind=true
    local i=0

    if [[ ${O_PRE} == true ]]
    then
        outPrefix "${p}"
    fi

    for l in ${@:-}
    do
        tmp="${l/#$SCRIPT_PWD/.}"
        if [[ "$(echo $tmp | wc -m)" != "$((($(echo $l | wc -m) + 1)))" ]]
        then
            l="${tmp}"
        fi

        len=$((($(echo "${l}" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'| wc -m) + $len + 1)))

        if [[ ${len} -gt ${L_MAX} ]]
        then
            len=$(echo "${l}" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | wc -m)
            ind=true
            newLine
            if [[ ${O_PRE} == true ]]
            then
                outPrefix "${p}"
            fi
        fi

        if [[ ${O_PRE} != true ]]
        then
            O_PRE=true
        fi

        if [[ ${i} == 0 ]]
        then
            SEQ=${O_SPACE}
        else
            SEQ=${O_SEC_SPACE}
        fi

        if [[ $len == 0 ]] || [[ $ind == true ]]
        then
            for i in $(seq 1 ${SEQ})
            do
                l=" $l"
            done
            
            ind=false
            len=$((($length + 1)))
        fi

        echo -en "${C_RST}${C_TXT_DEFAULT}${C_TXT}${l}${C_RST} "

        i=$(((${i} + 1)))
    done

    if [[ ${O_NL} == true ]]
    then
        newLine
        O_NL=true
    else
        O_NL=true
    fi

    O_SPACE=1
    O_SEC_SPACE=1
    O_PRE=true
}

function outTitle()
{
    local p="${1:---}"
    local l="${2:-BLOCK}"
    local s="${3:-true}"

    if [[ $s == true ]]
    then
        outPrefix ${p} true
        outLines ${p} "${C_HDR_DEFAULT}${C_HDR}${l}"
    else
        outLines ${p} "${C_HDR_DEFAULT}${C_HDR}${l}"
    fi

    if [[ $s == true ]]; then outPrefix ${p} true; fi
}

function outPrefix()
{
    if [[ ${3} != true ]]; then echo -en "  "; fi

    echo -en "${C_PRE_DEFAULT}${C_PRE}${1}"

    if [[ ${2} == true ]]; then newLine; fi
}

function outBlkL()
{
    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    outTitle  ${p} ${t}
    outLines  ${p} ${l[@]}
    outPrefix ${p} true

    newLine
}

function outBlkS()
{
    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    O_NL=false
    outTitle ${p} "${t}" false
    O_PRE=false
    O_SPACE=0
    outLines ${p} ${l[@]}

    newLine
}

function outBlkM()
{
    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    outTitle ${p} "${t}" false
    outLines ${p} ${l[@]}

    newLine
}

function colorSet()
{
    if [[ -n ${1} ]] && [[ ${1} != false ]]; then C_PRE="${1}"; fi
    if [[ -n ${2} ]] && [[ ${1} != false ]]; then C_HDR="${2}"; fi
    if [[ -n ${3} ]] && [[ ${1} != false ]]; then C_TXT="${3}"; fi
}

function colorReset()
{
    C_TXT=""
    C_PRE=""
    C_HDR=""
}

function outWelcome()
{
    colorSet "${COLOR_L_WHITE}" "${COLOR_U_WHITE}" "${COLOR_WHITE}"
    local p="--"
    local t="${@:1}"
    local l="${@:2}"
    local f=true

    outPrefix ${p} true
    outTitle ${p} ${t}
    outPrefix ${p} true
    for word in ${l[@]}
    do
        if [[ "${word:0:1}" == "@" ]] && [[ ${f} == false ]]
        then
            outLines ${p} ${line}
            line="${word:1}"
        elif [[ ${f} == true ]]
        then
            line="${word:1}"
            f=false
        else
            line="${line} ${word}"
        fi
    done
    outLines ${p} ${line}
    outPrefix ${p} true
    newLine
    colorReset
}

function opStart()
{
    colorSet "${COLOR_L_WHITE}" "${COLOR_L_WHITE}"
    outBlkL "--" "BEGN" "${@}"
    colorReset
}

function opDone()
{
    colorSet "${COLOR_L_WHITE}" "${COLOR_L_WHITE}"
    outBlkL "--" "EXIT" "${@}"
    colorReset
}

function opFail()
{
    colorSet "${COLOR_L_WHITE}" "${COLOR_L_WHITE}"
    outBlkL "--" "FAIL" "${@}"
    colorReset
}

function opExec()
{
    colorSet "${COLOR_L_PURPLE}" "${COLOR_L_PURPLE}"
    outBlkS "++" "EXEC" "${@}"
    colorReset
}

function outInfo()
{
    colorSet "${COLOR_YELLOW}" "${COLOR_YELLOW}"
    outBlkS ">>" "INFO" "${@}"
    colorReset
}

function outWarning()
{
    colorSet "${COLOR_L_RED}" "${COLOR_L_RED}"
    outBlkS "!!" "WARN" "${@}"
    colorReset
}

function outError()
{
    colorSet "${COLOR_L_RED}" "${COLOR_B_RED}" "${COLOR_L_WHITE}"
    outBlkL "##" "CRIT" "${@}"
    colorReset
    exit -1
}

function outComplete()
{
    colorSet "${COLOR_L_GREEN}" "${COLOR_L_GREEN}" "${COLOR_L_WHITE}"
    outBlkL "--" "DONE" "${@}"
    colorReset
}

function outListing()
{
    local lines=("$@")
    local iterations=${#lines[@]}
    local leftMaxLength=0
    local iterationRemainder=0
    local prefix="-- "

    for i in $(seq 0 1 $(((${iterations} - 1))))
    do
        line="${lines[${i}]}"
        value="${lines[$(((${i} + 1)))]}"

        if [[ "${line:0:1}" == ":" ]] || [[ "${line}" == "_" ]]
        then
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})
            continue
        fi

        if [[ $(((${i} % 2))) != ${iterationRemainder} ]]
        then
            continue
        fi

        wc=$(echo -n "${line}" | wc -m)
        [[ ${wc} -gt ${leftMaxLength} ]] && leftMaxLength=${wc}
    done

    iterationRemainder=0
    leftMaxLength=$(((${leftMaxLength} + 3)))
    C_PRE=${COLOR_WHITE}

    echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"

    for i in $(seq 0 1 $(((${iterations} - 1))))
    do
        line="${lines[${i}]}"
        value="${lines[$(((${i} + 1)))]}"

        if [[ "${line:0:1}" == ":" ]]
        then
            title="${line:1}"
            titleSurround=""
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})

            for j in $(seq $(echo -n ${title} | wc -m))
            do
                titleSurround="${titleSurround}-"
            done

            [[ $i != 0 ]] && echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}\n  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"
            echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}${COLOR_WHITE}${title^^}${C_RST}"
            echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"

            continue
        fi

        if [[ "${line}" == "_" ]]
        then
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})

            echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"
            continue
        fi

        if [[ $(((${i} % 2))) != ${iterationRemainder} ]]
        then
            continue
        fi

        dotCount=$(((${leftMaxLength} - $(echo ${line} | wc -m) + 2)))

        echo -en "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"
        echo -en "${C_RST}${C_TXT_DEFAULT}${C_TXT}"
        echo -en "${line} "
        for i in $(seq 1 ${dotCount})
        do
            echo -en "${COLOR_B_BLACK}.${C_RST}"
        done
        echo -e " ${COLOR_L_WHITE}${value/#$SCRIPT_PWD/.}${C_RST}"
    done

    echo -e "  ${C_PRE_DEFAULT}${C_PRE}${prefix}${C_RST}"

    newLine
    colorReset
}

function inverseBoolValueAsInt()
{
    if [[ ${1:-x} == 0 ]]
    then
        echo 1
    else
        echo 0
    fi
}

function parseYaml()
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')

   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function getMajorPHPVersion()
{
    if [ ${VER_PHP_ON_5} ]
    then
        echo "5"
    elif [ ${VER_PHP_ON_7} ]
    then
        echo "7"
    else
        echo "x"
    fi
}

function isExtensionEnabled()
{
    ${BIN_PHP} -m 2> /dev/null | grep ${1} &>> /dev/null

    if [ $? -eq 0 ]
    then
        echo "true"
    else
        echo "false"
    fi
}

function commaToOtherSeparated()
{
    echo $(echo $(echo "${1}" | tr ',' "${2}"))
}

function commaToSpaceSeparated()
{
    commaToOtherSeparated "${1}" " "
}

function valueInList()
{
    local needle="${1:-x}"
    local haystack="${2:-}"

    for item in $(commaToSpaceSeparated ${haystack})
    do
        echo $item
        if [ ${item} == ${needle} ]
        then
            echo "true"
            return
        fi
    done

    echo "false"
}

function assignIndirect()
{
    if [ "${1:-x}" == "x" ]; then return; fi

    export -n "${1}"="${2:-}"
}

function getYesOrNoForCompare()
{
    if [[ "${1:-x}" == "${2:-y}" ]]
    then
        echo "YES"
    else
        echo "NO"
    fi
}

# EOF #
