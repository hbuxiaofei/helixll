#!/bin/bash

INSTALL_BIN=/usr/local/bin
export PATH=$INSTALL_BIN:$PATH

INSTALL_HOME=$HOME
[ -n "$SUDO_USER" ] && INSTALL_HOME=/home/$SUDO_USER

cd $(dirname $0)

if command -v hx >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] hx command already exist\033[0m"
else
    check_os=$(rpm -qa 2>/dev/null | grep release | grep el9.x86_64)
    if [ -n "$check_os" ]; then
        wget https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/h/helix-24.03-2.el9.x86_64.rpm
        rpm -ivh helix-24.03-2.el9.x86_64.rpm
    else
        if [ ! -e helix-24.03-x86_64-linux.tar.gz ]; then
            wget https://github.com/hbuxiaofei/helixll/releases/download/v0.3.0/helix-24.03-x86_64-linux.tar.gz
        fi
        if [ -e helix-24.03-x86_64-linux.tar.gz ]; then
            tar -xf helix-24.03-x86_64-linux.tar.gz --strip-components 1 -C /usr/
        fi
    fi
fi

[ ! -d $INSTALL_BIN ] && mkdir -p $INSTALL_BIN

if ! command -v hx >/dev/null 2>&1; then
    echo -e "\033[33m- [Err] hx command install failed\033[0m"
    exit 1
fi

if command -v xplr >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] xplr command already exist\033[0m"
else
    if [ ! -e xplr-linux-x86_64.v0.21.7.tar.gz ]; then
        wget https://github.com/hbuxiaofei/helixll/releases/download/v0.2.0/xplr-linux-x86_64.v0.21.7.tar.gz
    fi
    if [ -e xplr-linux-x86_64.v0.21.7.tar.gz ]; then
        tar -xf xplr-linux-x86_64.v0.21.7.tar.gz
        mv xplr ${INSTALL_BIN}/
    fi
fi

if ! command -v xplr >/dev/null 2>&1; then
    echo -e "\033[33m- [Err] xplr command install failed\033[0m"
    exit 1
fi

if command -v rust-analyzer  >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] rust-analyzer command already exist\033[0m"
else
    if [ ! -e rust-analyzer-x86_64-unknown-linux-gnu.gz ]; then
        wget https://github.com/rust-lang/rust-analyzer/releases/download/2024-01-29/rust-analyzer-x86_64-unknown-linux-gnu.gz
    fi

    if [ -e rust-analyzer-x86_64-unknown-linux-gnu.gz ]; then
        gunzip rust-analyzer-x86_64-unknown-linux-gnu.gz
        chmod +x rust-analyzer-x86_64-unknown-linux-gnu
        mv rust-analyzer-x86_64-unknown-linux-gnu ${INSTALL_BIN}/rust-analyzer
    fi
fi

if ! command -v rust-analyzer >/dev/null 2>&1; then
    echo -e "\033[33m- [Err] rust-analyzer command install failed\033[0m"
    exit 1
fi


if command -v fzf >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] fzf command already exist\033[0m"
else
    if [ ! -e fzf-0.50.0-linux_amd64.tar.gz ]; then
        wget https://github.com/junegunn/fzf/releases/download/0.50.0/fzf-0.50.0-linux_amd64.tar.gz
    fi

    if [ -e fzf-0.50.0-linux_amd64.tar.gz ]; then
        tar -xvf fzf-0.50.0-linux_amd64.tar.gz
        chmod +x fzf
        mv fzf ${INSTALL_BIN}/
    fi
fi
if ! command -v fzf >/dev/null 2>&1; then
    echo -e "\033[33m- [Err] fzf command install failed\033[0m"
    exit 1
fi


if command -v bat >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] bat command already exist\033[0m"
else
    if [ ! -e bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz ]; then
        wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
    fi

    if [ -e bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz ]; then
        tar -xvf bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
        chmod +x bat-v0.24.0-x86_64-unknown-linux-gnu/bat
        mv bat-v0.24.0-x86_64-unknown-linux-gnu/bat ${INSTALL_BIN}/ && rm -rf bat-v0.24.0-x86_64-unknown-linux-gnu
    fi
fi
if ! command -v bat >/dev/null 2>&1; then
    echo -e "\033[33m- [Err] bat command install failed\033[0m"
    exit 1
fi

if [ ! -d ${INSTALL_HOME}/.config/xplr ]; then
    mkdir -p ${INSTALL_HOME}/.config/xplr
fi
cp -rf xplr-config/* ${INSTALL_HOME}/.config/xplr/

if [ ! -d ${INSTALL_HOME}/.config/helix ]; then
    mkdir -p ${INSTALL_HOME}/.config/helix
fi
cp -f helix-vim/config.toml ${INSTALL_HOME}/.config/helix/
cp -rf themes  ${INSTALL_HOME}/.config/helix/

cp -f ./languages.toml ${INSTALL_HOME}/.config/helix/

cat > ${INSTALL_BIN}/helix << EOF
#!/bin/bash
if [ -z "\$1" ]; then
    hx \$(fzf --no-mouse --height 80% --layout=reverse --ansi --preview 'bat --color=always --line-range=:100 {}')
else
    hx \$@
fi
exit 0
EOF
chmod +x ${INSTALL_BIN}/helix

echo -e "\033[32m- [Info] Install successfully...\033[0m"

exit 0
