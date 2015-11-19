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

if [ ${VER_PHP_ON_5:-x} == "x" ]
then
	outNotice "Skipping coverage/analytics for non-PHP 5.x versions (found ${VER_PHP})."
	exit 0
fi

for c in $(commaToSpaceSeparated ${scr_pkg_ci_send_req})
do
	c_opts=""
	c_bin="bin/${c}"
	c_exit=0
	[[ "${c}" == "codacycoverage" ]] && c_opts="clover -n ${COV_PATH}"
	[[ "${c}" == "coveralls" ]] && c_opts="-vvv"

	if [[ ! -f "${c_bin}" ]]
	then
		outError \
			"Could not run ${c_bin} as requires binary does not exist." && \
			continue
	fi

	outInfo "Running ${c_bin}"
	${c_bin} ${c_opts} &>> /dev/null || c_exit=-1

	[[ ${c_exit} != 0 ]] && outError \
		"Command ${c_bin} exited with non-zero return value."
done

# EOF #
