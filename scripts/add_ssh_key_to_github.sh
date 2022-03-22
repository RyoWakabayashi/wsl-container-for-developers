#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    SSH 鍵を GitHub に登録する

    構文: ./${ME}

EOE

    exit

}

login_to_gh() {

    gh auth login -p https -h github.com -s admin:public_key -w

}

# shellcheck disable=SC2154
add_ssh_key() {

    gh ssh-key add ~/.ssh/id_rsa.pub -t wsl

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

    login_to_gh
    add_ssh_key

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
