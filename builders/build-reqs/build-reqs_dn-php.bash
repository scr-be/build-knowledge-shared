#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

readonly SCRIPT_BUILDR_SPATH="${0}"
readonly SCRIPT_BUILDR_RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}" 2> /dev/null)" && pwd)"
readonly SCRIPT_BUILDR_NAME="$(basename ${SCRIPT_CALLER_SPATH} 2> /dev/null)"

type outLines &>> /dev/null || exit -1

opStart \
	"Submitting code coverage results."

if [ ${VER_PHP_ON_5:-x} == "x" ]
then
	outInfo "Skipping for version ${VER_PHP} of PHP."
	exit 0
else
	COV_ERROR=false

	for c in $(commaToSpaceSeparated ${scr_pkg_ci_send_req})
	do
		c_opts=""
		c_bin="bin/${c}"
		c_exit=0
		[[ "${c}" == "codacycoverage" ]] && c_opts="clover -n ${COV_PATH}"
		[[ "${c}" == "coveralls" ]] && c_opts="-vvv"

		if [[ ! -f "${c_bin}" ]]
		then
			outWarning \
				"Could not run ${c_bin} as required binary does not exist." && \
				COV_ERROR=true && \
				continue
		fi

		opExec "${c_bin} ${c_opts} &>> /dev/null || c_exit=-1"
		${c_bin} ${c_opts} &>> /dev/null || c_exit=-1

		[[ ${c_exit} != 0 ]] && outWarning \
			"Command ${c_bin} exited with non-zero return value." && \
			COV_ERROR=true
	done
fi

if [[ ${COV_ERROR} ]]
then
	opFail \
		"Submitting code coverage results."
else
	opDone \
		"Submitting code coverage results."
fi

# EOF #
