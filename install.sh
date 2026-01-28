#!/bin/bash

INSTALL_BIN=/usr/local/bin
export PATH=$INSTALL_BIN:$PATH

INSTALL_HOME=$HOME
[ -n "$SUDO_USER" ] && INSTALL_HOME=/home/$SUDO_USER

cd $(dirname $0)

HX_VERSION="25.07.1-5"
if command -v hx >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] hx command already exist\033[0m"
else
    check_el9=$(uname -r 2>/dev/null | grep "el9.x86_64")
    check_el10=$(uname -r 2>/dev/null | grep "el10.x86_64")
    if [ -n "$check_el9" ]; then
        if [ ! -e helix-${HX_VERSION}.el9.x86_64.rpm ]; then
            wget https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/h/helix-${HX_VERSION}.el9.x86_64.rpm
        fi
        rpm -ivh helix-${HX_VERSION}.el9.x86_64.rpm
    elif [ -n "$check_el10" ]; then
        if [ ! -e helix-${HX_VERSION}.el10_2.x86_64.rpm ]; then
            wget https://dl.fedoraproject.org/pub/epel/10/Everything/x86_64/Packages/h/helix-${HX_VERSION}.el10_2.x86_64.rpm
        fi
        rpm -ivh helix-${HX_VERSION}.el10_2.x86_64.rpm
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

if [ ! -d ${INSTALL_HOME}/.config/helix ]; then
    mkdir -p ${INSTALL_HOME}/.config/helix
fi
cp -f helix-vim/config.toml ${INSTALL_HOME}/.config/helix/
cp -f helix-vim/hx-git ${INSTALL_HOME}/.config/helix/ && chmod +x ${INSTALL_HOME}/.config/helix/hx-git
cp -f helix-vim/hx-picker ${INSTALL_HOME}/.config/helix/ && chmod +x ${INSTALL_HOME}/.config/helix/hx-picker
cp -rf themes ${INSTALL_HOME}/.config/helix/

cp -f ./languages.toml ${INSTALL_HOME}/.config/helix/

cat > ${INSTALL_BIN}/helix << HELIX_EOF
#!/bin/bash

TEMP_LAYOUT=\$(mktemp)

cat > "\$TEMP_LAYOUT" << EOF
default_mode "locked"
show_startup_tips false
mouse_mode false
advanced_mouse_actions false
pane_frames false
on_force_close "quit"
copy_on_select false
disable_session_metadata true

keybinds clear-defaults=true {
    locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
    }
    shared_except "locked" {
        bind "Ctrl g" { SwitchToMode "locked"; }
    }
}

layout {
    pane name="helix-editor" {
        command "hx"
        args "\$@"
        close_on_exit true
    }
    pane size=1 borderless=true {
       plugin location="zellij:status-bar"
    }
}
EOF

zellij --layout \$TEMP_LAYOUT

rm -f "\$TEMP_LAYOUT"
HELIX_EOF

chmod +x ${INSTALL_BIN}/helix

echo -e "\033[32m- [Info] Install successfully...\033[0m"

exit 0
