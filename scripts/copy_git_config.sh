#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    Git 設定を WSL 上にコピーする

    構文: ./${ME}

EOE

    exit

}

copy_git_files() {

    input_file="$(wslpath "$(wslvar USERPROFILE)")"/.gitconfig

    cp "${input_file}" ~/

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

    copy_git_files

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
