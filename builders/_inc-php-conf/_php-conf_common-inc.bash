#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export RT_COMMANDS_RET=0
export RT_COMMANDS_ACT=()
export RT_COMMANDS_ACT_FB=()
export RT_COMMANDS_INC=false

for e in "${RT_INCS[@]}"
do
    RT_COMMANDS_ACT+=("${BIN_PHPENV} config-add ${RT_PATH}/${RT_FILE}inc-${e}.ini")
done

RT_COMMANDS_ACT+=("${BIN_PHPENV} rehash")

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

# EOF #
