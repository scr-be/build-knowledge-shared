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

if [ ${VER_PHP_ON_7} ]
then
	outLines "Skipping coverage uploads for PJP v7."
	exit
fi

COVERAGE_CLOVER="build/logs/clover.xml"

if [ ! -e "${COVERAGE_CLOVER}" ]
then
	outError "Could not locate clover XML files at ${COVERAGE_CLOVER}"
else
	bin/coveralls -vvv

	if [ ${CODACY_PROJECT_TOKEN:-x} == "x" ]
	then
		outError "Please set CODACY_PROJECT_TOKEN."
	else
		bin/codacycoverage clover -n ${COVERAGE_CLOVER}
	fi
fi

# EOF #
