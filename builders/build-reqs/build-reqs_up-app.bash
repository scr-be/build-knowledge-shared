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

for e in $(commaToSpaceSeparated ${scr_pkg_symfony_req})
do
	APP_CMDS=()
	opStart \
		"Executing \"${e}\" application command."

	opExec "source ${INC_SYMF_PATH}/${INC_SYMF_FILE}${e}.bash"
	. "${INC_SYMF_PATH}/${INC_SYMF_FILE}${e}.bash"

	opDone \
		"Executing \"${e}\" application command."
done

# EOF #
