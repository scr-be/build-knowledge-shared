#!/bin/bash

ROOT_DIR="/www/scribe-tools_star-open/repos"
WORK_DIR="${ROOT_DIR}/.tmp"
CFG_FILE=".scribe-package.yml"
GIT_CFG_REMOTE="https://github.com/scr-be/build-knowledge-shared.git"
GIT_CFG_RDIR="./.config"
SUB_CFG_RDIR="./app/config/shared_public"
CFG_RUNNER="./build/doc/generate-api-docs.php"
REPOS=("wonka-library" "wonka-bundle")

# thanks github@pkuczynski: https://gist.github.com/pkuczynski/8665367
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function dply_info()
{
    echo "PROJECT API UPDATE SCRIPT"
    echo "by Rob Frawley 2nd <rmf@scr.be>"
    echo ""
}

function make_dirs()
{
    echo "Removing prior used dir(s):"
    echo " - 1/1: ${WORK_DIR}"
    rm -fr "${WORK_DIR}" &>> /dev/null
    echo ""

    echo "Creating required dir(s):"
    echo " - 1/2: ${ROOT_DIR}"
    mkdir -p "${ROOT_DIR}"
    echo " - 2/2: ${WORK_DIR}"
    mkdir -p "${WORK_DIR}"
    echo ""

    echo "Entering work dir: ${WORK_DIR}"
    echo ""
}

function clone_one()
{
    number="${1}"
    shortn="${2}"
    remote="https://github.com/scr-be/${shortn}.git"
    tmpdir="${WORK_DIR}/${shortn}"
    cfgfile="${WORK_DIR}/${CFG_FILE}"

    cd "${WORK_DIR}"

    echo " - ${number}/${#REPOS[@]} [ $r ]"
    echo "     - Obtaining source :"
    echo -n "         - [ extern ] Fetching : '${remote}'"
    git clone "${remote}" "${tmpdir}" &>> /dev/null && echo " ... done."

    cd "${tmpdir}"

    echo "     - Configuring : "

    if [ -e "${cfgfile}" ]; then
        echo "         - [  read  ] YML Filepath    : '${cfgfile}'"
        eval $(parse_yaml "${cfgfile}" "cfg_pkg_")

        if [ -z ${cfg_pkg_api_parser+x} ]; then
            echo "         ! [  stop  ] No parser configured."
            return
        elif [ "${cfg_pkg_api_parser}" == "sami" ] || [ "${cfg_pkg_api_parser}" == "~" ]; then
            echo "         - [  conf  ] Src Parser Type : 'sami'."
            cfg_pkg_api_parser="sami"
            cfg_pkg_api_binary="${tmpdir}/vendor/sami/sami/sami.php"
        else
            echo "         ! [  stop  ] Unsuported parser requested: '${cfg_pkg_api_parser}'."
            return
        fi

        if [ -z ${cfg_pkg_api_branch+x} ] || [ "${cfg_pkg_api_branch}" == "~" ]; then
            echo "         - [  conf  ] Git Branch      : 'origin/master'."
            cfg_pkg_api_branch="origin/master"
        fi

        if [ -z ${cfg_pkg_api_cfgmod} ]; then
            echo "         ! [  stop  ] You must provide a 'api_cfgmod' value."
            return            
        elif [ "${cfg_pkg_api_cfgmod}" == "submodule" ]; then
            echo "         - [  conf  ] Config Mode     : 'git submodule'."
        elif [ "${cfg_pkg_api_cfgmod}" == "clone" ] || [ "${cfg_pkg_api_cfgmod}" == "~" ]; then
            echo "         - [  conf  ] Config Mode     : 'git remote clone'."
        else
            echo "         ! [  stop  ] Unsuported config handling '${cfg_pkg_api_cfgmod}'."
            return
        fi

        if [ ! -z ${cfg_pkg_api_runner} ] && [ "${cfg_pkg_api_runner}" != "~" ]; then
            echo "         - [  conf  ] Src Runner Path : '${cfg_pkg_api_runner}'."
            cfg_pkg_api_runner="${tmpdir}/${cfg_pkg_api_runner}"
        fi
    else
        echo "         - [  read  ] No config file found!"
        cfg_pkg_api_branch="origin/master"
        cfg_pkg_api_cfgmod="clone"
        cfg_pkg_api_parser=""
        cfg_pkg_api_runner="~"
        cfg_pkg_api_binary="${tmpdir}/vendor/sami/sami/sami.php"
    fi

    echo "     - Setup Local Repo :"
    echo -n "         - [ extern ] Running : 'git fetch'"
    git fetch &>> /dev/null && echo " ... done."
    echo -n "         - [ extern ] Running : 'git checkout -b '${cfg_pkg_api_branch}''"
    git checkout -b "${cfg_pkg_api_branch}" &>> /dev/null  && echo " ... done."
    echo "         - [  info  ] Commit  : '$(git show --oneline | head -n 1 | cut -d" " -f1)'"
    echo "         - [  info  ] Message : '$(git show --oneline | head -n 1 | cut -d" " -f2-)'"

    echo "     - Configure runner:"
    if [ "${cfg_pkg_api_cfgmod}" == "submodule" ]; then
        echo "         - [ depend ] Updating : 'git submodules'"
        git submodule init &>> /dev/null
        git submodule update &>> /dev/null
        echo " ... done."
        if [ -z ${cfg_pkg_api_runner} ] || [ "${cfg_pkg_api_runner}" == "~" ]; then
            cfg_pkg_api_runner="${tmpdir}/${SUB_CFG_RDIR}/${CFG_RUNNER}"
            echo "         - [ depend ] Runner   : '${cfg_pkg_api_runner}'"
        fi
    else
        echo -n "         - [ remote ] Fetching : '${GIT_CFG_REMOTE}'"
        git clone "${GIT_CFG_REMOTE}" "${GIT_CFG_RDIR}" &>> /dev/null
        echo " ... done."
        if [ -z ${cfg_pkg_api_runner} ] || [ "${cfg_pkg_api_runner}" == "~" ] || [ "${cfg_pkg_api_runner}" == "" ]; then
            cfg_pkg_api_runner="${tmpdir}/${GIT_CFG_RDIR}/${CFG_RUNNER}"
            echo "         - [ depend ] Runner   : '${cfg_pkg_api_runner}'"
        fi
    fi

    COMPOSER_BIN=$(which composer)
    echo "     - Installing deps :"
    echo "         - [ binary ] Found   : 'composer' as '${COMPOSER_BIN}'"
    echo -n "         - [ extern ] Running : '${COMPOSER_BIN} install || ${COMPOSER_BIN} update'"
    ${COMPOSER_BIN} install &>> /dev/null || ${COMPOSER_BIN} update &>> /dev/null
    echo " ... done."
    if [ ! -e "${cfg_pkg_api_binary}" ]; then
        echo "             - [ misdep ] Dependency missing  : 'sami/sami'"
        echo "             - [ depend ] Manual require      : 'sami/sami'"
        echo -n "             - [ extern ] Running             : '${COMPOSER_BIN} require --dev sami/sami'"
        ${COMPOSER_BIN} require --dev sami/sami &>> /dev/null && echo " ... done."
        if [ ! -e "${cfg_pkg_api_binary}" ]; then
            echo "         ! [  stop  ] Cannot meet required dependencies!"
            return
        fi
        echo "         - [ depend ] Resolved : 'sami/sami'"
    fi

    if [ -z "${cfg_pkg_api_paths}" ]; then
        PHP_PATHS=""
    else
        PHP_PATHS="${cfg_pkg_api_paths}"
    fi
    PHP_BIN=$(which php)

    echo "     - Issuing runner  :"
    echo "     -   - [ binary ] Found   : 'php' as '${PHP_BIN}'"
    echo -n "         - [ extern ] Running : 'printf "YES\\n" | ${PHP_BIN} "${cfg_pkg_api_runner}" "${tmpdir}" "${shortn}"'"
    printf "YES\n" | ${PHP_BIN} "${cfg_pkg_api_runner}" "${tmpdir}" "${shortn}" ${PHP_PATHS} &>> /dev/null && echo " ... done."

    echo "     - Running cleanup :"
    echo -n "         - [   rm   ] Temporary conf  : '${GIT_CFG_RDIR}'"
    rm -fr "${GIT_CFG_RDIR}" && echo " ... done."
    if [ -d "${tmpdir}/app" ]; then
        echo -n "         - [   rm   ] Application dir : '${tmpdir}/app'"
        rm -fr "${tmpdir}/app" && echo " ... done."
    fi
    echo -n "         - [   rm   ] Vendor dir      : '${tmpdir}/vendor'"
    rm -fr "${tmpdir}/vendor" && echo " ... done."

    if [ -d "${ROOT_DIR}/${shortn}" ]; then
        echo -n "         - [   rm   ] Prior rendering : '${ROOT_DIR}/${shortn}'"
        rm -fr "${ROOT_DIR}/${shortn}" && echo " ... done."
    fi

    echo -n "         - [  move  ] New rendering   : '${ROOT_DIR}/${shortn}'"
    mv "${tmpdir}" "${ROOT_DIR}/${shortn}" && echo " ... done."

    if [ -d "${ROOT_DIR}/${shortn}" ]; then
        echo "     - [ result ] Complete!"
    fi
}

function clone_all()
{
    echo "Re-cloning ${#REPOS[@]} repositories and re-creating API reference:"

    let i=1
    for r in "${REPOS[@]}"; do
        clone_one "${i}" "${r}"
        echo ""
        i="$((($i+1)))"
    done
}

function main()
{
    dply_info
    make_dirs
    clone_all
}

main

