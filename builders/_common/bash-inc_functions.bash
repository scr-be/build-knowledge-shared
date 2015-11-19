#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

function outLines()
{
    local p="${1:---}"
    local l    

    shift
    l="${@:-}"

    if [ "${l}" ]
    then
        echo -n "${l[@]}" | sed -r "s/(.{1,110})/  ${p}  \1\n/g"
    else
        echo -n " " | sed -r "s/(.{1,110})/  ${p}  \1\n/g"
    fi
}

function outBlock()
{
    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    outLines ${p}
    outLines ${p} ${t}
    outLines ${p} ${l[@]}
    outLines ${p}
    echo -en "\n"
}

function outBlockNoHeader()
{
    local p="${1:---}"
    local l="${@:2}"

    outLines ${p}
    outLines ${p} ${l[@]}
    outLines ${p}
    echo -en "\n"
}

function outInfo()
{
    outBlockNoHeader "--" "${@}"
}

function outError()
{
    outBlock "!!" "ERROR" "${@}"
}

function outCritical()
{
    outBlock "!!" "CRITICAL ERROR" "${@}"
}

function outNotice()
{
    outBlockNoHeader "##" "${@}"
}

function outSuccess()
{
    outBlockNoHeader ">>" "${@}"
}

function outErrorAndExit()
{
    outError ${@:-An unknown error occured.}
    outCritical "Halting execution with non-zero return value."
    exit -1
}

function outListing()
{
    local lines=("$@")
    local iterations=${#lines[@]}
    local leftMaxLength=0
    local iterationRemainder=0
    local prefix="- "

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

            [[ $i != 0 ]] && echo -e "  ${prefix}\n  ${prefix}"
            echo "  ${prefix}  [ ${title^^} ]"
            echo "  ${prefix}"

            continue
        fi

        if [[ "${line}" == "_" ]]
        then
            iterationRemainder=$(inverseBoolValueAsInt ${iterationRemainder})

            echo "  ${prefix}"
            continue
        fi

        if [[ $(((${i} % 2))) != ${iterationRemainder} ]]
        then
            continue
        fi

        echo -en "  ${prefix}  "
        echo -n "${line} " | sed -e :a -e "s/^.\{1,${leftMaxLength}\}$/&./;ta";
        echo " ${value}"
    done
    
    echo -en "\n"
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
