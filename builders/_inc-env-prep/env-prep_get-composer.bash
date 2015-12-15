#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RT_COMMANDS_ACT=(
	"${BIN_CURL} -o ${DIR_CWD}/composer.raw -sS https://getcomposer.org/installer"
    "${BIN_PHP} ${DIR_CWD}/composer.raw -- --filename=composer --install-dir=${DIR_CWD}"
    "rm -fr ${DIR_CWD}/composer.raw"
    "chmod u+x ${DIR_CWD}/composer"
)

# EOF #
