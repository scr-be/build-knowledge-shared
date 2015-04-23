#!/bin/bash

if [ -z "${1}" ]
then
    echo "Usage: ./${0} path/to/search"
    exit 1
fi

if [ -z "${2}" ]
then
    find_search_ext="php"
else
    find_search_ext="${2}"
fi

required_bins=(php5 realpath)
required_bins_error=0
result_error_count=0
result_warning_count=0

echo -e "SIMPLE PHP LINTER (v0.1.0)"
echo -e "  Written by Rob Frawley <rmf@scr.be>."
echo -e "  Distributed under the MIT License."
echo -e "  Copyright (c) 2015 Scribe Inc <scribenet.com>."

for bin in ${required_bins[@]}
do
    which_ret="$(which ${bin} > /dev/null 2>&1)"
    if [ "$?" != "0" ]
    then
        if [ "${required_bins_error}" == "0" ]
        then
            echo -e "\n[RUNTIME ERRORS]"
        fi
        echo -e "  The '${bin}' binary is required."
        required_bins_error=1
    fi
done

if [ "${required_bins_error}" != "0" ]
then
    echo -e "\nResolve any of the above errors and try again."
    exit 1
fi

find_search_path="$(realpath ${1})"

echo -e "\n[CONFIGURATION]"
echo -e "  Scaning directory  : "${find_search_path}""
echo -e "  Matching extension : "${find_search_ext}""
echo -e "\n[LINTING FILES] "

for file in `find "${find_search_path}" -iname "*.${find_search_ext}"`
do
    file_ext="${file##*.}"

    if [ "${file_ext}" == "${find_search_ext}" ]
    then

        file_ret_error="$(php -l $file 2> /dev/null)"

        if [ "$file_ret_error" != "No syntax errors detected in $file" ]
        then
            echo -en "E"
            result_error_files[result_error_count]="${file}"
            result_error_messages[result_error_count]="${file_ret_error}"
            ((result_error_count++))
        fi

        file_ret_warning="$(php -l $file 2>&1 > /dev/null)"

        if [ "x$file_ret_warning" != "x" ]
        then
            echo -en "W"
            result_warning_files[result_warning_count]="${file}"
            result_warning_messages[result_warning_count]="${file_ret_warning}"
            ((result_warning_count++))
        fi

        if [ "$file_ret_error" == "No syntax errors detected in $file" ] && [ "x$file_ret_warning" == "x" ]
        then
            echo -en "."
        fi
    fi
done

echo -e "\n\n[RESULTS]"
echo -e "  Errors   : ${result_error_count}"
echo -e "  Warnings : ${result_error_count}"

if [ "${result_error_count}" != "0" ] || [ "${result_warning_count}" != "0" ]
then
    echo -e "\n[DETAILS]"

    if [ "${result_error_count}" != "0" ]
    then
        for i in "${!result_error_files[@]}"
        do
            echo -en "  - $(printf "%02d" $(((${i}+1)))) "
            echo -en "[$(basename ${result_error_files[${i}]})] "
            echo -en "${result_error_messages[${i}]}\n"
        done
    fi

    if [ "${result_warning_count}" != "0" ]
    then
        for i in "${!result_warning_files[@]}"
        do
            echo -en "  - $(printf "%02d" $(((${result_error_count}+${i}+1)))) "
            echo -en "[$(basename ${result_warning_files[${i}]})] "
            echo -en "${result_warning_messages[${i}]}\n"
        done
    fi
fi

echo -en "\n"

# EOF
