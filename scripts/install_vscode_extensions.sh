#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    VSCode の拡張機能を一括インストールする

    構文: ./${ME}

EOE

    exit

}

install_extensions() {

    xargs -n1 code --install-extension < ./configs/vscode_extensions.txt

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

    install_extensions

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
