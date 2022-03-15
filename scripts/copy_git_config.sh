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

    copy_git_files

}

main "$@"

exit 0
