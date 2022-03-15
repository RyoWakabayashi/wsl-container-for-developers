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

    copy_aws_files

}

main "$@"

exit 0
