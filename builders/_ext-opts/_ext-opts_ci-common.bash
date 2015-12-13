#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export INC_EOPT_RT_MODE="ci"
export INC_EOPT_RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_ci_ops}))

if [ ${VER_PHP_ON_5:-x} == "x" ]
then
	outInfo "Skipping CI operations when running v${VER_PHP} of PHP."
else
	opSource "${INC_EOPT_PATH}/_${INC_EOPT_FILE}common.bash"
	. "${INC_EOPT_PATH}/_${INC_EOPT_FILE}common.bash"
fi

# EOF #
