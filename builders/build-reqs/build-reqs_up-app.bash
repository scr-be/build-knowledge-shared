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
	export RT_MODE="app prep"
	export RT_MODE_APPEND=false
	export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_app_prep}))
	export RT_PATH=${INC_APP_PREP_PATH}
	export RT_FILE=${INC_APP_PREP_FILE}
elif [[ "${ACTION}" == "dn-app" ]]
then
	export RT_MODE="app post"
	export RT_MODE_APPEND=false
	export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_app_post}))
	export RT_PATH=${INC_APP_POST_PATH}
	export RT_FILE=${INC_APP_POST_FILE}
fi

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

# EOF #
