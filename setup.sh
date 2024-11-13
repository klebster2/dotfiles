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
    apt-get install tmux >/dev/null || sudo apt-get install tmux
}

install_tmux_completion() {
    tmux -V >/dev/null || check_user_input "tmux" "install_tmux"
    curl -o $HOME/.dotfiles/tmux.completion.bash \
        "https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash"
}

install_fzf() {
    # TODO add as a submodule
    git clone --depth 1 "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
    "$HOME/.fzf/install"
}

install_fzf_git() {
    # TODO add as a submodule
    git clone --depth 1 "https://github.com/junegunn/fzf-git.sh" "$HOME/.fzf-git"
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
    dotfiles="$(dirname "$(realpath "$0")")"

    # defaults
    if_exists_bak "$HOME/.bashrc" && ln -sv "$dotfiles/bashrc" "$HOME/.bashrc"
    if_exists_bak "$HOME/.bash_functions" && ln -sv "$dotfiles/bash_functions" "$HOME/.bash_functions"
    if_exists_bak "$HOME/.bash_aliases" && ln -sv "$dotfiles/bash_aliases" "$HOME/.bash_aliases"

    # keybindings (use vi mode rather than emacs)
    if_exists_bak "$HOME/.inputrc" && ln -sv "$dotfiles/inputrc" "$HOME/.inputrc"

    # extras
    if_exists_bak "$HOME/.tmux.conf" && ln -sv "$dotfiles/tmux.conf" "$HOME/.tmux.conf"

    # fzf
    if_exists_bak "$HOME/.fzf.bash" && ln -sv "$dotfiles/fzf.bash" "$HOME/.fzf.bash"

    # curl
    if_exists_bak "$HOME/.curlrc" && ln -sv "$dotfiles/curlrc" "$HOME/.curlrc"

    # gitconfig
    if_exists_bak "$HOME/.gitconfig" && ln -sv "$dotfiles/gitconfig" "$HOME/.gitconfig"

    # Installations
    if [[ "$1" == "all" ]]; then
        install_fzf
        install_fzf_git
        install_tmux_completion
        install_tpm
        install_nvim_config
    else
        check_user_input "fzf - fuzzy file finder" "install_fzf"
        check_user_input "fzf-git.sh" "install_fzf_git"
        check_user_input "tmux completer" "install_tmux_completion"
        check_user_input "tpm - tmux plugin manager" "install_tpm"
        check_user_input "nvim configuration - klebster2" "install_nvimconfig"
    fi
fi
