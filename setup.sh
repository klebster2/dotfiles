#!/bin/bash

if_exists_bak() {
    if [[ -f "${1}" && ! -L "${1}" && ! -f "${1}.bak" ]]; then
        # do not overwrite bak
        mv "${1}"{,.bak}
    elif [[ -f "${1}" && ! -L "${1}" && -f "${1}.bak" ]]; then
        # write new bak suffix
        count=1
        while true; do
            if [[ ! -f "${1}.${count}.bak" ]]; then
                mv "${1}.${count}"{,.bak}
                ((count++))
            fi
        done
    fi
}

if_exists_bak "$HOME/.bashrc"; ln -sv "$HOME/.dotfiles/.bashrc" "$HOME/.bashrc"
if_exists_bak "$HOME/.inputrc"; ln -sv "$HOME/.dotfiles/.inputrc" "$HOME/.inputrc"
if_exists_bak "$HOME/.tmux.conf"; ln -sv "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"

