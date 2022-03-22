#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    SSH 設定と SSH 鍵を WSL 上に生成する

    構文: ./${ME}

EOE

    exit

}

generate_keys() {

    ssh-keygen -f "${HOME}/.ssh/id_rsa"

}

# shellcheck disable=SC2154
generate_configs() {

    local ssh_config="${HOME}/.ssh/config"

    cp "${HOME}/scripts/ssh_config_template" "${ssh_config}"

    proxy_connect=${http_proxy/http:\/\//}

    [ -n "${http_proxy}" ] && \
        echo "  ProxyCommand nc -X connect -x ${proxy_connect/:/\\:} %h %p" >> "${ssh_config}"

    chmod 600 "${ssh_config}"

}

# shellcheck disable=SC2038
add_keys_to_agent() {

    find ~/.ssh/ -type f -exec grep -l "PRIVATE" {} + | \
        xargs ssh-add &> /dev/null

}

main() {

    while getopts h opt; do
        case $opt in
            h)
                display_usage
            ;;
            \?)
                whoopsie "Invalid option!"
            ;;
        esac
    done

    generate_keys
    generate_configs

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
