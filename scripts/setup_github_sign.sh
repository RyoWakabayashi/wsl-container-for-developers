#!/bin/bash

set -uo pipefail
set -e

readonly ME=${0##*/}

display_usage() {

    cat <<EOE

    GPG 鍵を WSL 上に生成する

    構文: ./${ME}

EOE

    exit

}

generate_keys() {

    local conf="${HOME}/scripts/gpg.conf"

    cp "${HOME}/scripts/gpg_template.conf" "${conf}"

    echo "あなたの氏名を入力して下さい."
    read -r p_name

    echo "あなたのメールアドレスを入力して下さい."
    read -r p_email

    echo "パスフレーズを入力して下さい."
    read -r p_passphrase

    sed -i \
        -re "s?Pname?${p_name}?g" \
        -re "s?Pemail?${p_email}?g" \
        -re "s?Ppassphrase?${p_passphrase}?g" \
        "${conf}"

    gpg --gen-key --batch "${conf}"

    gpg --export-secret-keys \
        --armor \
        --batch \
        --yes \
        --pinentry-mode=loopback \
        --passphrase "${p_passphrase}" \
        --output "${HOME}/.${p_name}.pgp" \
        "${p_name}"

    gh auth login -p https -h github.com -s write:gpg_key -w

    gh gpg-key add "${HOME}/.${p_name}.pgp"

    local key_id
    key_id=$( \
        gpg --list-signatures \
            --with-colons | \
            grep 'sig' | \
            grep "${p_name}" | \
            head -n 1 | \
            cut -d':' -f5
    )

    git config --global user.name "${p_name}"
    git config --global user.email "${p_email}"
    git config --global user.signingkey "${key_id}"
    git config --global commit.gpgsign true

    rm "${conf}"

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

}

whoopsie() {

    local message=$1

    echo "${message} Aborting..."
    exit 192

}

main "$@"

exit 0
