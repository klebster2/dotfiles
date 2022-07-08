#!/bin/bash
# CAUTIONARY NOTE: Aliases may interfere with other commands!
# >>> custom shortcuts >>>
alias fwh="find_windows_home"

# Useful command to switch user email / password between
alias guc="git_config_change_user_credentials"

# to use when finding all function names
# TODO: make this recursive with maxdepth
alias bff="findbashfunctions $HOME/.bash_functions"

# show all functions
alias sf='showfunc'
# e.g. run
# ff # -> then using the list, you should be able to find the func name
# e.g. you needed to find venv but couldn't remember the name exactly
# sf venv # -> check what the function does

# source bashrc
alias sb='source $HOME/.bashrc'

# e.g. you can use something like
# sudo ssh $(srp 8087 8088) -o ServerAliveInterval=30 user@localhost -i ~/.ssh/authorized_keys/key.ssh -p 2249
alias srp='ssh_repeat_localhost_port'

alias si="bind -f $HOME/.inputrc"

# edit config
alias ei="$EDITOR $HOME/.inputrc"
alias eb="$EDITOR $HOME/.bashrc"
alias ebh="edit_history $HOME/.bash_eternal_history | $EDITOR -"
alias et="$EDITOR $HOME/.tmux.conf"
alias ev="$EDITOR $HOME/.vim_runtime/nvim/lua/init.vim"
alias eV="$EDITOR $HOME/.vim_runtime/nvim"  # higher level view over vim/nvim files

# change directory
alias cdv="cd $HOME/.vim_runtime"
alias cdd="cd $HOME/.dotfiles"
alias cdh="cd $HOME"
alias si="bind -f $HOME/.inputrc"
alias dl="dailylog"
alias dT="date"
alias dt="date +%T"

# editor aliases
alias nv='nvim'
alias vimdiff='nvim -d'
alias nvdiff='nvim -d'
alias nvd='nvim -d'
# NOTE: To access vim use \vim, this will not access neovim

# python finders
alias pff='python_find_files'
alias pipconf='python -m pip config debug'

# clean extraneous python files that are not useful to keep in git
alias rmps='rm_pyshit'
alias rmpys='rm_pyshit'
