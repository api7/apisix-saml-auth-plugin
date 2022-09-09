#!/usr/bin/env bash

set -exuo pipefail

VAR_CUR_HOME="$(cd $(dirname ${0})/../..; pwd)"

# =======================================
# Linux common config
# =======================================
export_or_prefix() {
    export OPENRESTY_PREFIX="/usr/local/openresty-debug"
    export PATH=$OPENRESTY_PREFIX/nginx/sbin:$OPENRESTY_PREFIX/luajit/bin:$OPENRESTY_PREFIX/bin:$PATH
}


get_apisix_code() {
    # ${1} branch name
    # ${2} checkout path
    git_branch=${1:-master}
    git_checkout_path=${2:-workbench}
    git clone --depth 1 --recursive https://github.com/apache/apisix.git \
        -b "${git_branch}" "${git_checkout_path}" && cd "${git_checkout_path}" || exit 1
}


patch_apisix_code(){
    # ${1} apisix home dir
    VAR_APISIX_HOME="${VAR_CUR_HOME}/${1:-workbench}"

    (cd $VAR_APISIX_HOME; patch -p1 < $VAR_CUR_HOME/ci/saml-auth.patch)
}


install_module() {
    # ${1} apisix home dir
    VAR_APISIX_HOME="${VAR_CUR_HOME}/${1:-workbench}"

    # copy ci utils script
    cp -av "${VAR_CUR_HOME}/ci" "${VAR_APISIX_HOME}"

    # copy custom apisix folder to origin apisix
    cp -av "${VAR_CUR_HOME}/apisix" "${VAR_APISIX_HOME}"

    # copy test case to origin apisix
    cp -av "${VAR_CUR_HOME}/t" "${VAR_APISIX_HOME}"
}


run_case() {
    export_or_prefix

    ./bin/apisix init
    ./bin/apisix init_etcd

    FLUSH_ETCD=1 prove -I./ t/plugin/saml-auth.t
}

# =======================================
# Entry
# =======================================
case_opt=$1
shift

case ${case_opt} in
get_apisix_code)
    get_apisix_code "$@"
    ;;
patch_apisix_code)
    patch_apisix_code "$@"
    ;;
install_module)
    install_module "$@"
    ;;
run_case)
    run_case "$@"
    ;;
*)
    echo "Unknown method: ${case_opt}"
    exit 1
    ;;
esac
