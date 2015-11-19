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

for e in $(echo $(echo "${scr_pkg_syspkgs_req}" | tr ',' " "))
do
	bash "${SCRIPT_BUILDR_RPATH}/../_ext-deps/ext-deps_make-${e}.bash"
done

for e in $(echo $(echo "${scr_pkg_phpexts_req}" | tr ',' " "))
do
	bash "${SCRIPT_BUILDR_RPATH}/../_php-mods/php-mods_make-${e}.bash"
done

if [ ${BIN_PHPENV} ]
then
	${BIN_PHPENV} config-add "${SCRIPT_BUILDR_RPATH}/../_php-incs/php-incs_set-timezone.ini" &>> /dev/null || true
	${BIN_PHPENV} rehash
fi

# EOF #
