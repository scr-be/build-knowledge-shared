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
        echo -n "${l[@]}" | sed -r "s/(.{1,74})/  ${p}  \1\n/g"
    else
        echo "  ${p}"
    fi
}

function outBlock()
{
    local p="${1:---}"
    local t="${2:-BLOCK}"
    local l="${@:3}"

    echo -en "\n"
    outLines ${p}
    outLines ${p} ${t}
    outLines ${p} ${l[@]}
    outLines ${p}
    echo -en "\n"
}

function outInfo()
{
    outBlock "--" "INFO:" "${@}"
}

function outError()
{
    outBlock "!!" "ERROR:" "${@}"
}

function outSuccess()
{
    outBlock ">>" "OKAY:" "${@}"
}

function outErrorAndExit()
{
    outError ${@:-An unknown error occured.}

    exit -1
}

function outListing()
{
    echo -en "\n  ++\n  ++  LISTING:\n"
    local lines=(${@})
    local iterations=${#lines[@]}

    if [ $((($iterations % 2))) == 0 ]
    then
        for i in $(seq 1 2 ${iterations})
        do
            echo "  ++  ${lines[$(((${i} - 1)))]} -> ${lines[${i}]}"
        done
    fi

    echo -en "  ++\n"
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

function commaToSpaceSeparated()
{
    echo $(echo $(echo "${1:-}" | tr ',' " "))
}

function valueInList()
{
    local needle="${1:-x}"
    local haystack="${2:-}"

    for item in $(commaToSpaceSeparated ${haystack})
    do
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

# EOF #
