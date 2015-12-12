#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

SCRIPT_SELF_PATH="${0}"
SCRIPT_SELF_BASE="$(basename ${0})"
SCRIPT_SELF_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APP_MAKE_CMDS_PHP=(
    "doctrine:database:create -n"
    "doctrine:schema:create -n"
)

. ${SCRIPT_SELF_REAL}/_app-make_common.bash

# EOF #
