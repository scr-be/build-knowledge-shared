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

export RT_MODE="ci"
export RT_MODE_DESC="Enviornment Post-run"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_post}))
export RT_PATH=${INC_ENV_POST_PATH}
export RT_FILE=${INC_ENV_POST_FILE}

opSource "${INC_ENV_POST_PATH}/_${INC_ENV_POST_FILE}common.bash"
. "${INC_ENV_POST_PATH}/_${INC_ENV_POST_FILE}common.bash"

# EOF #
