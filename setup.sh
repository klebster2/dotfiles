#!/bin/bash

if_exists_bak() {
    if [[ ! -L "${1}" && -f "${1}" ]]; then
        # backup: case dotfile at location already exists
        if [[ ! -f "${1}.bak" ]]; then
            # do not overwrite current bak
            mv "${1}"{,.bak}
        else
            # write a new bak suffix if more baks exist
            count=1
            while true; do
                if [[ ! -f "${1}.${count}.bak" ]]; then
                    mv "${1}.${count}"{,.bak}
                    ((count++))
                fi
            done
        fi
        return 0
    elif [[ -L "${1}" ]]; then
        # symlink case
        echo "Symlink '${1}' -> '$(readlink -f $1)' already exists"
        return 1
    else
        printf "no file ${1} found\nAdding ${1}...\n"
        return 0
    fi
}

install_tmux() {
    if uname | grep -q Darwin; then
        brew install tmux
    else
        apt-get install tmux
    fi
}

install_tmux_completion() {
    tmux -V >/dev/null || check_user_input "tmux" "install_tmux"
    curl -o $HOME/.dotfiles/tmux.completion.bash \
        "https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash"
}



install_nvimconfig() {
    for tool in "jq -V" "curl -V" "unzip -v"; do
        if ! $tool > /dev/null ; then
            printf '%s is needed for this neovim setup. Please install before continuing' "$(echo "$tool" | cut -d " " -f1)" && exit -1
        fi
    done
    # TODO:
    #git submodule update
}

check_user_input() {
    local _prog="$1" _installer="$2"
    while true; do
        read -p "Do you want to install $_prog ? [Y/n]" y_n
        case "$y_n" in
            Y|y|Yes|yes ) $_installer ; break;;
            N|n|No|no ) echo "'${y_n}' $msg, skipping"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    echo
}

install_tpm() {
    # TODO add as a submodule
    [ -d "${HOME}/.tmux/plugins" ] || mkdir -pv "${HOME}/.tmux/plugins"
    git clone "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # If this is being used as a script
    DOTFILES="$(dirname "$(realpath "$0")")"

    if_exists_bak "$HOME/.bashrc" && ln -sv "$DOTFILES/bashrc" "$HOME/.bashrc"
    if_exists_bak "$HOME/.bash_functions" && ln -sv "$DOTFILES/bash_functions" "$HOME/.bash_functions"
    if_exists_bak "$HOME/.bash_aliases" && ln -sv "$DOTFILES/bash_aliases" "$HOME/.bash_aliases"
    if_exists_bak "$HOME/.inputrc" && ln -sv "$DOTFILES/inputrc" "$HOME/.inputrc"
    if_exists_bak "$HOME/.tmux.conf" && ln -sv "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"
    if_exists_bak "$HOME/.fzf.bash" && ln -sv "$DOTFILES/fzf.bash" "$HOME/.fzf.bash"
    if_exists_bak "$HOME/.curlrc" && ln -sv "$DOTFILES/curlrc" "$HOME/.curlrc"
    if_exists_bak "$HOME/.gitconfig" && ln -sv "$DOTFILES/gitconfig" "$HOME/.gitconfig"

    # Installations
    if [ -d "$DOTFILES/fzf" ]; then
        "$HOME/.fzf/install"
    fi
    if [ -d $DOTFILES/fzf-git.sh ]; then
        [ -d "$HOME/.fzf-git" ] || ln -s "$DOTFILES/fzf-git.sh/" "$HOME/.fzf-git"
    fi
    install_tmux_completion
    install_tpm
    install_nvimconfig
fi
