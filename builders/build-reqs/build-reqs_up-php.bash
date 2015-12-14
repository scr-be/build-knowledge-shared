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

export RT_MODE="env make"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_make}))
export RT_PATH=${INC_ENV_MAKE_PATH}
export RT_FILE=${INC_ENV_MAKE_FILE}

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

export RT_MODE="env prep"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_prep}))
export RT_PATH=${INC_ENV_PREP_PATH}
export RT_FILE=${INC_ENV_PREP_FILE}

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

for e in $(commaToSpaceSeparated ${scr_pkg_php_exts})
do
	opSource "${INC_PHP_EXTS_PATH}/_${INC_PHP_EXTS_FILE}common.bash"
	export MOD_NAME=${e}
	. "${INC_PHP_EXTS_PATH}/_${INC_PHP_EXTS_FILE}common.bash"
done

opStart "Setting up PHP configuration files."

if [ ${BIN_PHPENV} ]
then
	for e in $(commaToSpaceSeparated ${scr_pkg_php_conf})
	do
		opExec "${BIN_PHPENV} config-add ${INC_PHP_CONF_PATH}/${INC_PHP_CONF_FILE}inc-${e}.ini"
		${BIN_PHPENV} config-add "${INC_PHP_CONF_PATH}/${INC_PHP_CONF_FILE}inc-${e}.ini" &>> /dev/null || outWarning \
			"Could not add ${INC_PHP_CONF_FILE}${e}.ini to PHP config ini."
	done
	${BIN_PHPENV} rehash
else
	outWarning "Cannot add/setup configuration INI outside PHPENV enviornments."
fi

opDone \
	"Setting up PHP configuration files."

# EOF #
