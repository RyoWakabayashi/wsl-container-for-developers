#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    AWS 設定を WSL 上にコピーする

    構文: ./${ME}

EOE

    exit

}

copy_aws_files() {

    input_dir="$(wslpath "$(wslvar USERPROFILE)")"/.aws

    sudo cp -r "${input_dir}" ~/
    sudo chown ubuntu:ubuntu --recursive ~/.aws

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

    copy_aws_files

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
