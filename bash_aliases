#!/bin/bash

# CAUTIONARY NOTE: Aliases may interfere with other commands!
# >>> defaults >>>
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# <<< defaults <<<

# >>> custom shortcuts >>>
alias fwh="find_windows_home"

# Useful command to switch user email / password between
alias guc="git_config_change_user_credentials"

# to use when finding all function names
# TODO: make this recursive with maxdepth
alias bff="findbashfunctions $HOME/.bash_functions"

# edit configuration file
alias ei="$EDITOR $HOME/.inputrc"
alias eb="$EDITOR $HOME/.bashrc"
alias eba="$EDITOR $HOME/.bash_aliases"
alias aliases="cat $HOME/.bash_aliases|grep -P '^( *alias)'|sed 's/^ *//g'"
alias ebf="$EDITOR $HOME/.bash_functions"
alias et="$EDITOR $HOME/.tmux.conf"
alias ev="$EDITOR $HOME/.config/nvim/init.lua"
alias ep="$EDITOR $HOME/.config/nvim/lua/packer-startup.lua"
alias evcmp="$EDITOR $HOME/.config/nvim/lua/plugins/nvim-cmp-cfg.lua"
# view bash history with timestamps
alias ebh="edit_history $HOME/.bash_eternal_history | $EDITOR -"

# show all functions
alias sf='showfunc'
# e.g. run
# ff # -> then using the list, you should be able to find the func name
# e.g. you needed to find venv but couldn't remember the name exactly
# sf venv # -> check what the function does

# source bashrc
alias sb='source $HOME/.bashrc'
alias st='tmux source ~/.tmux.conf'

# e.g. you can use something like
# sudo ssh $(srp 8087 8088) -o ServerAliveInterval=30 user@localhost -i ~/.ssh/authorized_keys/key.ssh -p 2249
alias srp='ssh_repeat_localhost_port'

# change directory
alias cdv="cd $HOME/.config/nvim/"
alias cdd="cd $HOME/.dotfiles"
# source inputrc file
alias si="bind -f $HOME/.inputrc"

alias dl="dailylog"
alias dT="date"
alias dt="date +%T"

# editor aliases
alias nv='nvim'
alias nvd='nvim -d'
alias nvd='vimdiff'
# NOTE: To access vim use \vim, this will not access neovim

# python finders
alias pff='python_find_files'
alias pipconf='python -m pip config debug'

# clean extraneous python files that are not useful to keep in git
alias rm_pys='rm_pyshit'

# cheatsheet help e.g. ./cht.sh
alias cht="cht.sh"
alias chtsh="cht.sh"
