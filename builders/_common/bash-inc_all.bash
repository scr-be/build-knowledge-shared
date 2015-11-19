#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

readonly SCRIPT_COMMON_SPATH="${0}"
readonly SCRIPT_COMMON_RPATH="$(cd "$(dirname "${BASH_SOURCE[0]}" 2> /dev/null)" && pwd)"
readonly SCRIPT_COMMON_NAME="$(basename ${SCRIPT_CALLER_SPATH} 2> /dev/null)"

. ${SCRIPT_COMMON_RPATH}/bash-inc_functions.bash
. ${SCRIPT_COMMON_RPATH}/bash-inc_variables.bash
. ${SCRIPT_COMMON_RPATH}/bash-inc_common.bash

# EOF #
