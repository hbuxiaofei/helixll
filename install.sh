#!/bin/bash


cd $(dirname $0)


if command -v hx >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] hx(helix) command alreally installed\033[0m"
else
    check_os=$(rpm -qa 2>/dev/null | grep release | grep el9.x86_64)
    if [ -n "$check_os" ]; then
        wget https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/h/helix-24.03-2.el9.x86_64.rpm
        rpm -ivh helix-24.03-2.el9.x86_64.rpm
    else
        echo -e "\033[33m- [Err] helix only support el9.x86_64 now.\033[0m"
        exit 1
    fi
fi


if [ ! ~/.config/helix ]; then
    mkdir -p ~/.config/helix
fi
cp -f helix-vim/config.toml ~/.config/helix/

cp -f ./languages.toml ~/.config/helix/

echo -e "\033[32m- [Info] Install successfully...\033[0m"

exit 0
