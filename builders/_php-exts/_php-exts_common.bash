#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

SCRIPT_SELF_PATH="${0}"
SCRIPT_SELF_BASE="$(basename ${0})"
SCRIPT_SELF_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

type outLines &>> /dev/null || . ${SCRIPT_SELF_REAL}/../_common/bash-inc_all.bash

if [ -z ${MOD_NAME} ]
then
    MOD_NAME="$(basename ${SCRIPT_SELF_BASE} .bash)"
fi

MOD_SOURCE_CONFIG="${INC_PHP_EXTS_PATH}/php-$(getMajorPHPVersion)/${INC_PHP_EXTS_FILE}${MOD_NAME}.bash"

if [ ! -f ${MOD_SOURCE_CONFIG} ]
then
    outError "Could not find valid script \"${MOD_SOURCE_CONFIG}\"."
fi

opStart "Install \"${MOD_NAME}\" extension."

MOD_PECL_CMD=false
MOD_PECL_CMD_URL=false
MOD_PECL_DL=false
MOD_PECL_GIT=false
MOD_PECL_GIT_BRANCH="master"
MOD_PECL_GIT_DIR=""
MOD_PECL_FLAGS=""
MOD_PECL_CD=false
MOD_PECL_RET=0
MOD_RESULT=0

opSource "${MOD_SOURCE_CONFIG}"

. ${MOD_SOURCE_CONFIG}

MOD_PECL_LOG=$(getReadyTempFilePath "${LOG_EXT}${MOD_NAME//[^A-Za-z0-9._-]/_}.log")
MOD_PECL_BLD=$(getReadyTempPath "${BLD_EXT}${MOD_NAME//[^A-Za-z0-9._-]/_}")

if [[ $(isExtensionEnabled ${MOD_NAME}) == "true" ]] && [[ $(isExtensionPeclInstalled ${MOD_NAME}) == "true" ]]
then
    opExec "${CMD_PRE}pecl uninstall ${MOD_NAME} &>> /dev/null"

    ${CMD_PRE} pecl uninstall ${MOD_NAME} &>> ${MOD_PECL_LOG} || \
        outWarning "Failed to remove previous install; blindly attempting to continue anyway."
fi

if [[ ${MOD_PECL_CMD} != false ]]
then

    if [[ ${MOD_PECL_CMD_URL} == false ]]
    then
        MOD_PECL_CMD_URL="${MOD_NAME}"
    fi
    
    opLogBuild "${CMD_PRE}pecl install --force ${MOD_PECL_CMD_URL}" &&\
        opLogFlush

    printf "\n" | ${CMD_PRE} pecl install --force ${MOD_PECL_CMD_URL} &>> "${MOD_PECL_LOG}" || \
        MOD_PECL_RET=$?

elif [[ ${MOD_PECL_DL} != false ]] || [[ ${MOD_PECL_GIT} != false ]]
then

    opLogBuild "cd ${MOD_PECL_BLD}"

    cd ${MOD_PECL_BLD}

    if [[ ${MOD_PECL_DL} != false ]]
    then

        opLogBuild "${BIN_CURL} -o ${MOD_NAME}.tar.gz https://pecl.php.net/get/${MOD_NAME}"

        ${BIN_CURL} -o ${MOD_NAME}.tar.gz https://pecl.php.net/get/${MOD_NAME} &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

        opLogBuild "${BIN_TAR} xzf ${MOD_NAME}.tar.gz && cd [...]"

        ${BIN_TAR} xzf ${MOD_NAME}.tar.gz &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

    else

        opLogBuild "${BIN_GIT} clone ${MOD_PECL_GIT} ${MOD_NAME} && cd [...]" && \
            opLogBuild "${BIN_GIT} checkout ${MOD_PECL_GIT_BRANCH:-master}"

        ${BIN_GIT} clone -b ${MOD_PECL_GIT_BRANCH:-master} ${MOD_PECL_GIT} ${MOD_NAME} &>> ${MOD_PECL_LOG} || \
            MOD_PECL_RET=$?

    fi

    if [[ ${MOD_PECL_CD} != false ]] && [[ -d ${MOD_PECL_CD} ]]
    then
        cd ${MOD_PECL_CD} &>> ${MOD_PECL_LOG}
    elif [[ -d ${MOD_NAME} ]]
    then
        cd ${MOD_NAME} &>> ${MOD_PECL_LOG}
    else
        cd ${MOD_NAME}* &>> ${MOD_PECL_LOG}
    fi

    ${BIN_PHPIZE} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    opLogBuild "${BIN_PHPIZE}" && \
        opLogBuild "./configure ${MOD_PECL_FLAGS}" && \
        opLogBuild "${BIN_MAKE}" && \
        opLogBuild "${BIN_MAKE} install" && \
        opLogFlush

    printf "\n" | ./configure ${MOD_PECL_FLAGS} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    ${BIN_MAKE} &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    ${BIN_MAKE} install &>> ${MOD_PECL_LOG} || \
        MOD_PECL_RET=$?

    cd "$DIR_CWD"
fi

if [[ ${MOD_PECL_RET} == 0 ]] && [[ $(isExtensionEnabled ${MOD_NAME}) != "true" ]]; then
    if [ ${BIN_PHPENV} ]
    then
        opExec "${BIN_PHPENV} config-add ${INC_PHP_CONF_PATH}/${INC_PHP_CONF_FILE}use-${MOD_NAME}.ini"

        ${BIN_PHPENV} config-add "${INC_PHP_CONF_PATH}/${INC_PHP_CONF_FILE}use-${MOD_NAME}.ini" &>> /dev/null || \
            outWarning "Could not add ${INC_PHP_CONF_FILE}use-${MOD_NAME}.ini to PHP config."

        ${BIN_PHPENV} rehash
    else
        outInfo \
            "Auto-enabling extensions is only supported in phpenv environments." \
            "You need to add \"extension=${MOD_NAME}.so\" to enable the extension."
    fi
fi

if [[ ${MOD_PECL_RET} == 0 ]]
then
    opDone "Install \"${MOD_NAME}\" extension."
else
    opFailLogOutput "${MOD_PECL_LOG}" "${MOD_NAME}"
    opFail "Install \"${MOD_NAME}\" extension."
fi

# EOF #
