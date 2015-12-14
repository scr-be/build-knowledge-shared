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
export RT_MODE_DESC="Environment Make"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_make}))
export RT_PATH=${INC_ENV_MAKE_PATH}
export RT_FILE=${INC_ENV_MAKE_FILE}

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

export RT_MODE="env prep"
export RT_MODE_DESC="Environment Prepare"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_env_prep}))
export RT_PATH=${INC_ENV_PREP_PATH}
export RT_FILE=${INC_ENV_PREP_FILE}

opSource "${RT_PATH}/_${RT_FILE}common.bash"
. "${RT_PATH}/_${RT_FILE}common.bash"

export RT_MODE="use"
export RT_MODE_DESC="PHP Extension Install"
export RT_MODE_APPEND=false
export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_php_exts}))
export RT_PATH=${INC_PHP_EXTS_PATH}
export RT_FILE=${INC_PHP_EXTS_FILE}

opSource "${RT_PATH}/_${RT_FILE}common-exts.bash"
. "${RT_PATH}/_${RT_FILE}common-exts.bash"

if [ ${BIN_PHPENV} ]
then
    export RT_MODE="inc"
    export RT_MODE_DESC="PHP INI Config"
    export RT_MODE_APPEND=false
    export RT_INCS=($(commaToSpaceSeparated ${scr_pkg_php_conf}))
    export RT_PATH=${INC_PHP_CONF_PATH}
    export RT_FILE=${INC_PHP_CONF_FILE}

    opSource "${RT_PATH}/_${RT_FILE}common-inc.bash"
    . "${RT_PATH}/_${RT_FILE}common-inc.bash"
else
	outWarning "Cannot add/setup configuration INI outside PHPENV environments."
fi

# EOF #
