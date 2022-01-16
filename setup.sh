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

install_vimrc() {
    git clone "https://github.com/klebster2/myvimrc" ~/.vim_runtime
    pushd ~/.vim_runtime
    ./install_vimrc.sh
    popd
}

install_tmux_completion() {
    pushd "$HOME/.dotfiles/"
    curl -o tmux.completion.bash \
        "https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash"
    popd
}

if_exists_bak "$HOME/.bashrc" && ln -sv "$HOME/.dotfiles/bashrc" "$HOME/.bashrc"
if_exists_bak "$HOME/.inputrc" && ln -sv "$HOME/.dotfiles/inputrc" "$HOME/.inputrc"
if_exists_bak "$HOME/.tmux.conf" && ln -sv "$HOME/.dotfiles/tmux.conf" "$HOME/.tmux.conf"

install_tmux_completion

conda > /dev/null 2>&1 \
|| curl -Lo Miniconda3-latest-Linux-x86_64.sh \
   "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
   && chmod +x ./Miniconda3-latest-Linux-x86_64.sh \
   && ./Miniconda3-latest-Linux-x86_64.sh

while true; do
    read -p "Do you wish to install klebster2's vimrc ? [Y/n]" yn
    case $yn in
        [Yy]* ) install_vimrc; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
