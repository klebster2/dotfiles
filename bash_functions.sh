#!/bin/bash

# Functions without args - can be used in bash pipeline
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
    # seconds to hours minutes seconds (the verbose version)
    awk '{SUM+=$1}END{printf "S: %d\nH:M:S: %d:%d:%d\n",SUM,SUM/3600,SUM%3600/60,SUM%60}'
}

sum_time() {
    xargs soxi -D \
      | awk '{SUM+=$1} END {printf"%d:%d:%d\n", SUM/3600, SUM%3600/60, SUM%60}'
}

hms2s() {
    awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'
}

findbashfunctions() {
    # meta function
    for file in $@; do
        grep -P "^(function )?[a-zA-Z]\w+\(\) {" "$file" \
            | sed -r 's/\(\).*$//g'
    done
}

source_bashrc() {
    source "$HOME/.bashrc"
}

dailylog() {
    [ ! -e "$HOME/.dailylog" ] && mkdir "$HOME/.dailylog"
    "$EDITOR" "$HOME/.dailylog/$(date +%d_%m_%y)"
}


# Functions with args.
docker_rm_stop() {
    docker stop $1
    docker rm $1
}

venv() {
    local python_version="$1"
    dir="./venv"
    [ ! -d "$dir" ] && python$python_version -m venv "$dir"
}

showfunc() {
    # Show the function definition
    # See https://stackoverflow.com/questions/6916856/can-bash-show-a-functions-definition#answer-6916952
    what_is="$(type $1)"
    if (echo "$what_is" | head -n1 | grep -q "$1 is a function"); then
        echo "$what_is" | sed '1,3d;$d' | sed -r 's/^ {,4}//g'
    fi
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

edit_history() {
    local bash_history_file="$1"
    perl -pe \
        'use POSIX qw(strftime); s/^#(\d+)/strftime "#%F %H:%M:%S", localtime($1)/e' \
        "$1" 
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

env_add() {
    local env="$1"
    python -m ipykernel install --user --name="$env"
}

search_history() {
    edit_history $HOME/.bash_eternal_history \
        | awk -e '
            BEGIN {RS = "\n"} {
                if ($0 ~ /^#[[:digit:] ]*/)
                    {
                        printf "%s\t",$0
                    }
                else {
                    print $0
                }
            }' \
        | sort -r | fzf | cut -d $'\t' -f2-
}

# >>> custom shortcuts >>>

# CAUTIONARY NOTE: Aliases may interfere with other commands!
alias fwh="find_windows_home"
alias guc="git_config_change_user_credentials"
alias ff="findbashfunctions ${HOME}/.bashrc $HOME/.dotfiles/.bashrc_functions.sh"
alias sf='showfunc'
# e.g. run
# ff
# sf venv
alias sb='source_bashrc'
alias srp='ssh_repeat_localhost_port'
alias si="bindrc $HOME/.inputrc"

# edit
alias ei="$EDITOR $HOME/.inputrc"
alias eb="$EDITOR $HOME/.bashrc"
alias ebh="edit_history $HOME/.bash_eternal_history | $EDITOR -"
alias et="$EDITOR $HOME/.tmux.conf"
alias ev="$EDITOR $HOME/.vim_runtime/vimrcs/basic.vim"
alias cdv="cd $HOME/.vim_runtime"
alias si="bind -f $HOME/.inputrc"
alias dl="dailylog"
alias dT="date"
alias dt="date +%T"

alias nv='nvim'
alias vimdiff='nvim -d'
alias nvd='nvim -d'
# to access vim run \vim, this will not access neovim

