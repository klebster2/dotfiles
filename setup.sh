#!/bin/bash

ln -s ~/.dotfiles/.bashrc ~
ln -s ~/.dotfiles/.inputrc ~
ln -s ~/.dotfiles/.tmux.conf ~

tmux source-file ~/.tmux.conf
