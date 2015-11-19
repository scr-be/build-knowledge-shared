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

for e in $(commaToSpaceSeparated ${scr_pkg_syspkgs_req})
do
	outInfo "Running ${INC_SYSR_PATH}/${INC_SYSR_FILE}${e}.bash"
	. "${INC_SYSR_PATH}/${INC_SYSR_FILE}${e}.bash"
done

for e in $(commaToSpaceSeparated ${scr_pkg_phpexts_req})
do
	outInfo "Running ${INC_MODS_PATH}/${INC_MODS_FILE}${e}.bash"
	export PHP_MODULE=${e}
	. "${INC_MODS_PATH}/${INC_MODS_FILE}${e}.bash"
done

if [ ${BIN_PHPENV} ]
then
	for e in $(commaToSpaceSeparated ${scr_pkg_phpincs_req})
	do
		outInfo "Adding PHP config ${INC_INCS_PATH}/${INC_INCS_FILE}${e}.ini"
		${BIN_PHPENV} config-add "${INC_INCS_PATH}/${INC_INCS_FILE}${e}.ini" &>> /dev/null || outErrorAndExit \
			"Could not add ${INC_INCS_FILE}${e}.ini to PHP config ini."
	done
	${BIN_PHPENV} rehash
else
	outNotice "Cannot add/setup configuration INI outside PHPENV enviornments."
fi

# EOF #
