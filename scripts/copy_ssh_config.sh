#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    SSH 設定を WSL 上にコピーする

    構文: ./${ME}

EOE

    exit

}

copy_ssh_files() {

    input_dir="$(wslpath "$(wslvar USERPROFILE)")"/.ssh

    cp -r "${input_dir}" ~/

}

# shellcheck disable=SC2038
set_permissions() {

    find ~/.ssh/ -type f -exec grep -l "PRIVATE" {} + | \
        xargs chmod 600 &> /dev/null

}

# shellcheck disable=SC2154
replace_configs() {

    proxy_connect=${http_proxy/http:\/\//}

    [ -z "${http_proxy}" ] && \
        proxy_command="" || \
        proxy_command="ProxyCommand nc -X connect -x ${proxy_connect/:/\\:} %h %p"

    sed -i \
        -re "s@C.+\.ssh\\\@${HOME}/.ssh/@g" \
        -re "s@ProxyCommand.+@${proxy_command}@g" \
        ~/.ssh/config

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

    copy_ssh_files
    set_permissions
    replace_configs
    add_keys_to_agent

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
