#!/bin/bash

#
# Include some additional commands in your path that can be called against your git tree.
# For example: 
# - `git php-lint`
# - `git large-files`
# - etc...
#
# Additional scripts are available as well, include ones not applicable to calling via `git`.
# This script 
# Intended to be included via your ~/.bashrc file.
#

set -e

readonly SCR_PUBLIC_CONFIG_SCRIPTS_ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GIT_PATH_ROOT=""
GIT_PATH_SEARCHES=()
USR_PATH_SEARCH_METHOD="absolute"
USR_PATH_SEARCH=""

function locate_closest_git_root_under()
{
	local srch_depth=20
	local path_decmt="$(readlink -f ${SCR_PUBLIC_CONFIG_SCRIPTS_ABSOLUTE_PATH})"
	local path_steps=()
	local find_lines=0

	while [[ "${path_decmt}" != "/" && ${#path_steps[@]} -lt $srch_depth ]];
	do
		path_steps+=("$path_decmt")
		find_lines=$(find "${path_decmt}" -maxdepth 1 -mindepth 1 -type d -name \.git | wc -l)

		if [[ "${find_lines}" == "1" ]];
		then
			GIT_PATH_ROOT=$(readlink -f $path_decmt)
			break
		fi

		path_decmt="$(readlink -f $path_decmt/..)"
	done

	GIT_PATH_SEARCHES=("${path_steps[@]}") 
}

function locate_possible_gitmodules_file_and_check_path()
{
	local path_relative=""

	test ! -f "${GIT_PATH_ROOT}/.gitmodules" && USR_PATH_SEARCH="${SCR_PUBLIC_CONFIG_SCRIPTS_ABSOLUTE_PATH}" && return

	for path in "${GIT_PATH_SEARCHES[@]}";
	do
		path_relative="${path/${GIT_PATH_ROOT}/}"

		if [[ -z "${path_relative}" ]]; then
			break
		fi

		path_relative=("${path_relative#\/}")

		if [[ $(grep -P '[\s\t]{1,}path\s?=\s?('"${path_relative}"')$' "${GIT_PATH_ROOT}/.gitmodules" 2> /dev/null | wc -l) == "1" ]];
		then
			USR_PATH_SEARCH_METHOD="relative"
			USR_PATH_SEARCH="${path_relative}"
		fi

	done
}

function main()
{
	cd "${SCR_PUBLIC_CONFIG_SCRIPTS_ABSOLUTE_PATH}"

	locate_closest_git_root_under

	if [[ -z "${GIT_PATH_ROOT}" ]]; then
		exit 1
	fi

	locate_possible_gitmodules_file_and_check_path
}

main

export PATH="${SCR_PUBLIC_CONFIG_SCRIPTS_ABSOLUTE_PATH}:${PATH}"

# EOF
