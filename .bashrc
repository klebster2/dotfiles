# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend;

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#HISTSIZE=1000
#HISTFILESIZE=2000

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# activate colors
export TERM=xterm-256color

export EDITOR="nvim"
export VISUAL="nvim"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s autocd 2> /dev/null;
shopt -s globstar 2> /dev/null;
shopt -s nocaseglob 2> /dev/null;

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Functions without args.
bindrc() {
    bind -f $HOME/.inputrc
}

zombies()
{
    # find zombie prcs - `killall $(zombies | tr '\n' ' ')` kills all zombies
    for pid in $(ps axo pid=,stat= | awk '$2~/^Z/ { print $1 }') ; do
        echo "$pid"
    done
}

s2hms() {
    # seconds to hours minutes seconds
    awk '{SUM+=$1} END {printf"%d:%d:%d\n", SUM/3600, SUM%3600/60, SUM%60}'
}

s2hms_v() {
    # seconds to hours minutes seconds (verbose version)
    awk '{SUM+=$1}END{printf "S: %d\nH:M:S: %d:%d:%d\n",SUM,SUM/3600,SUM%3600/60,SUM%60}'
}

sum_time() {
    xargs soxi -D \
      | awk '{SUM+=$1} END {printf"%d:%d:%d\n", SUM/3600, SUM%3600/60, SUM%60}'
}

hms2s() {
    awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'
}

findbashrcfunctions() {
    # meta function
    grep -P "^(function )?[a-zA-Z]\w+\(\) {" "${HOME}/.bashrc" \
        | sed -r 's/\(\).*$//g'
}

# Functions with args.
docker_rm_stop() {
    docker stop $1
    docker rm $1
}

venv() {
    local python_version="$1"
    dir="./venv"
    [ -d "$dir" ] && python$python_version -m venv "$dir"
}

showfunc() {
    # Show the function definition
    # See https://stackoverflow.com/questions/6916856/can-bash-show-a-functions-definition#answer-6916952
    what_is="$(type $1)"
    if (echo "$what_is" | head -n1 | grep -q "$1 is a function"); then
        echo "$what_is" | sed '1,3d;$d' | sed -r 's/^ {,4}//g'
    fi
}

source_bashrc() {
    source "$HOME/.bashrc"
}

dailylog() {
    [ ! -e "$HOME/.dailylog" ] && mkdir "$HOME/.dailylog"
    "$EDITOR" "$HOME/.dailylog/$(date +%d_%m_%y)"
}

ssh_repeat_localhost_port() {
    # For SSH commands with tunnel redirects same server side as local side
    # this function simply helps the user to list a number of ports faster
    # e.g. to write
    # ssh -L 8080:localhost:8080 -L 8081:localhost:8081 \
    # -o ServerAliveInterval=30 k@localhost -i <ssh-keyfile> -p <port>
    # faster, we can do:

    # ssh "$(localhost_repeat_port 8080 8081)" or "$(srp 8080 8081)" ...
    # which will replace the string inside "$(..)" with a space separated list
    # e.g. "-L 8080:localhost:8080 -L 8081:localhost:8081"
    _stdout=" "
    for _port in $@; do
        _stdout="${_stdout}-L $_port:localhost:$_port "
    done
    echo "$_stdout"
}

edit_bash_history_file() {
    perl -pe \
        'use POSIX qw(strftime); s/^#(\d+)/strftime "#%F %H:%M:%S", localtime($1)/e' \
        "$HOME/.bash_eternal_history" | "$EDITOR" -
}

bakswp() {
    # simple helper for this common routine
    [ -e "$1.bak2" ] && exit 0
    cp $1{,.bak2}
    cp $1{.bak,}
    mv $1{.bak2,.bak}
}

disksp() {
    du $@ -Sh | sort -n -r | more
}

git_change_user_info() {
    local _option="$1"
    read -p "option: " value
    git config --local "$_option" "$value" && echo "successfuly changed" \
        || echo "unsuccessful"
}


git_config_change_user_info_option_prompt() {
    local _option="$1"
    echo "git config --get ${_option}"
    git config --get "${_option}"
    read -p "Change ${_option} (y/n)?" y_n
    msg="option selected"
    case "$y_n" in
        y|Y|Yes|yes ) echo "'${y_n}' $msg'"; git_change_user_info ${y_n};;
        n|N|No|no ) echo "'${y_n}' $msg, skipping";;
        * ) echo "invalid";;
    esac
}

git_config_change_user_credentials() {
    printf "Change name and email for current commit?\n"
    for option in user.name user.email; do
        git_config_change_user_info_option_prompt "$option"
    done
}

settitle() {
    # https://stackoverflow.com/questions/40234553/how-to-rename-a-pane-in-tmux
    export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
    echo -ne "\e]0;$1\a"
}

find_windows_home() {
    IFS=':' read -a fields <<<"$PATH"

    for field in "${fields[@]}"; do
            if [[ $field =~ ^(/mnt/.*)/AppData/Local/.* ]]; then
                    echo ${BASH_REMATCH[1]}
                    exit
            fi
    done
}

# >>> custom shortcuts >>>

# CAUTIONARY NOTE: Aliases may interfere with other commands!
alias fwh="find_windows_home"
alias guc="git_config_change_user_credentials"
alias ff='findbashrcfunctions'
alias sf='showfunc'
# e.g. run
# ff
# sf venv
alias sb='source_bashrc'
alias srp='ssh_repeat_localhost_port'
alias si="bindrc $HOME/.inputrc"

# edit
alias ei="edit_file $HOME/.inputrc"
alias eb="edit_file $HOME/.bashrc"
alias ebh="edit_bash_history_file"
alias et="edit_file $HOME/.tmux.conf"
alias ev="edit_file $HOME/.vim_runtime/vimrcs/basic.vim"
alias cdv="cd $HOME/.vim_runtime"
alias si="bind -f $HOME/.inputrc"
alias dl="dailylog"
alias dT="date"
alias dt="date +%T"

alias nv='nvim'
alias vimdiff='nvim -d'
alias nvd='nvim -d'
# to access vim run \vim, this will not access neovim

# <<< custom shortcuts <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/kleber/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/kleber/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/kleber/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/kleber/miniconda3/bin:$PATH"
    fi
fi

unset __conda_setup
# <<< conda initialize <<<

export PATH="${HOME}/.local/bin:/bigdrive/kleber/environments/py3nvim/lib/python3.7:${PATH}"

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

[ -f "$HOME/.env-vars" ] && source "$HOME/.env-vars"

# remove duplicate PATHs for readability
# https://unix.stackexchange.com/questions/40749/remove-duplicate-path-entries-with-awk-command
export PATH_NOT_UNIQ="$PATH"
export PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

. "${HOME}/.env-vars"
source "${HOME}/.dotfiles/tmux.completion.bash"
