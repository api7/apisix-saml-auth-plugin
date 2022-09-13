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
    # no-op
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

    apt -y install libxml2-dev libxslt-dev openresty-openssl111-dev
    luarocks config variables.OPENSSL_DIR /usr/local/openresty/openssl111;
    luarocks install lua-resty-saml 0.2.2 --tree deps --local

    # run keycloak for saml test
    docker run --rm --name keycloak -d -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:18.0.2 start-dev

    # wait for keycloak ready
    bash -c 'while true; do curl -s localhost:8080 &>/dev/null; ret=$?; [[ $ret -eq 0 ]] && break; sleep 3; done'

    # configure keycloak for test
    wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq
    chmod +x jq
    docker cp jq keycloak:/usr/bin/
    docker cp ci/kcadm_configure_saml.sh keycloak:/tmp/
    docker exec keycloak bash /tmp/kcadm_configure_saml.sh

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
