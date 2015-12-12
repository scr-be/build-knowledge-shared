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

if [[ "${ACTION}" == "up-app" ]]
then
	APP_INCS=$(commaToSpaceSeparated ${scr_pkg_symf_up_req})
elif [[ "${ACTION}" == "dn-app" ]]
then
	APP_INCS=$(commaToSpaceSeparated ${scr_pkg_symf_dn_req})
fi

for e in ${APP_INCS}
do
	APP_CMDS=()
	APP_FILE="${INC_SYMF_PATH}/${INC_SYMF_FILE}${e}.bash"
	opStart \
		"Executing \"${e}\" application command."

	if [[ ! -f "${APP_FILE}" ]]
	then
		outWarning \
			"Application include ${APP_FILE} doesn't exist."
	fi

	opExec "source ${APP_FILE}"
	. "${APP_FILE}"

	opDone \
		"Executing \"${e}\" application command."
done

# EOF #
