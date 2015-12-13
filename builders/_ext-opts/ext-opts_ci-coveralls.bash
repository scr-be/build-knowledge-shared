#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##+

INC_EOPT_RT_CMDS=(
    "${BIN_PHP} $(readlink -m bin/coveralls) -vvv -x ${COV_PATH}"
)

# EOF #
