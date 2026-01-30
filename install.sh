#!/bin/bash

INSTALL_BIN=/usr/local/bin
export PATH=$INSTALL_BIN:$PATH

INSTALL_HOME=$HOME
[ -n "$SUDO_USER" ] && INSTALL_HOME=/home/$SUDO_USER

cd $(dirname $0) || exit 1

HX_VERSION="25.07.1"
if command -v hx >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] hx command already exist\033[0m"
else
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y -q helix
    fi
    if ! command -v hx >/dev/null 2>&1; then
        if [ ! -e helix-${HX_VERSION}-x86_64-linux.tar.xz ]; then
            wget https://github.com/helix-editor/helix/releases/download/${HX_VERSION}/helix-${HX_VERSION}-x86_64-linux.tar.xz
        fi
        if [ -e helix-${HX_VERSION}-x86_64-linux.tar.xz ]; then
            tar -xf helix-${HX_VERSION}-x86_64-linux.tar.xz -C ${INSTALL_BIN}/
            ln -sf ${INSTALL_BIN}/helix-${HX_VERSION}-x86_64-linux/hx ${INSTALL_BIN}/
        fi
    fi
fi
if ! command -v hx >/dev/null 2>&1; then
    echo -e "\033[31m- [Err] hx command install failed\033[0m"
    exit 1
fi

if command -v tig >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] tig command already exist\033[0m"
else
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y -q tig
    fi
fi
if ! command -v tig >/dev/null 2>&1; then
    echo -e "\033[33m- [Warn] tig command not found\033[0m"
fi


[ ! -d $INSTALL_BIN ] && mkdir -p $INSTALL_BIN

ZJ_VERSION="v0.43.1"
if command -v zellij >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] zellij command already exist\033[0m"
else
    if [ ! -e zellij-x86_64-unknown-linux-musl.tar.gz ]; then
        wget https://github.com/zellij-org/zellij/releases/download/${ZJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz
    fi
    if [ -e zellij-x86_64-unknown-linux-musl.tar.gz ]; then
        tar -xf zellij-x86_64-unknown-linux-musl.tar.gz -C ${INSTALL_BIN}/
    fi
fi
if ! command -v zellij >/dev/null 2>&1; then
    echo -e "\033[31m- [Err] zellij command install failed\033[0m"
    exit 1
fi

YZ_VERSION="v26.1.22"
if command -v yazi >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] yazi command already exist\033[0m"
else
    if [ ! -e yazi-x86_64-unknown-linux-musl.zip ]; then
        wget https://github.com/sxyazi/yazi/releases/download/${YZ_VERSION}/yazi-x86_64-unknown-linux-musl.zip
    fi

    if [ -e yazi-x86_64-unknown-linux-musl.zip ]; then
        unzip yazi-x86_64-unknown-linux-musl.zip
        mv yazi-x86_64-unknown-linux-musl/ya ${INSTALL_BIN}/
        mv yazi-x86_64-unknown-linux-musl/yazi ${INSTALL_BIN}/
        rm -rf yazi-x86_64-unknown-linux-musl
    fi
fi
if ! command -v yazi >/dev/null 2>&1; then
    echo -e "\033[31m- [Err] yazi command install failed\033[0m"
    exit 1
fi

DT_VERSION="0.18.2"
if command -v delta >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] delta command already exist\033[0m"
else
    if [ ! -e delta-${DT_VERSION}-x86_64-unknown-linux-musl.tar.gz ]; then
        wget https://github.com/dandavison/delta/releases/download/${DT_VERSION}/delta-${DT_VERSION}-x86_64-unknown-linux-musl.tar.gz
    fi

    if [ -e delta-${DT_VERSION}-x86_64-unknown-linux-musl.tar.gz ]; then
        tar -xf delta-${DT_VERSION}-x86_64-unknown-linux-musl.tar.gz
        mv delta-${DT_VERSION}-x86_64-unknown-linux-musl/delta ${INSTALL_BIN}/
        rm -rf delta-${DT_VERSION}-x86_64-unknown-linux-musl
    fi
fi
if ! command -v delta >/dev/null 2>&1; then
    echo -e "\033[31m- [Err] delta command install failed\033[0m"
    exit 1
fi

if command -v rust-analyzer  >/dev/null 2>&1; then
    echo -e "\033[32m- [Info] rust-analyzer command already exist\033[0m"
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
    echo -e "\033[31m- [Err] rust-analyzer command install failed\033[0m"
    exit 1
fi

if [ ! -d ${INSTALL_HOME}/.config/helix ]; then
    mkdir -p ${INSTALL_HOME}/.config/helix
fi

cp -f helix-vim/config.toml ${INSTALL_HOME}/.config/helix/

cp -f helix-vim/git-hx ${INSTALL_HOME}/.config/helix/
chmod +x ${INSTALL_HOME}/.config/helix/git-hx
ln -sf ${INSTALL_HOME}/.config/helix/git-hx ${INSTALL_BIN}/git-hx

cp -f helix-vim/picker-hx ${INSTALL_HOME}/.config/helix/
chmod +x ${INSTALL_HOME}/.config/helix/picker-hx

cp -f helix-vim/fff ${INSTALL_HOME}/.config/helix/
chmod +x ${INSTALL_HOME}/.config/helix/fff

cp -rf themes ${INSTALL_HOME}/.config/helix/
cp -f languages.toml ${INSTALL_HOME}/.config/helix/

cat > ${INSTALL_BIN}/helix << HELIX_EOF
#!/bin/bash

quoted_args=()
for arg in "\$@"; do
    quoted_args+=("\"\$arg\"")
done

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
styled_underlines false

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
        args \${quoted_args[*]}
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
