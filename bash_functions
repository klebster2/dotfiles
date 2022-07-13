#!/bin/bash
# >>> Functions without args - can be used in bash pipeline >>>
zombies() {
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

dailylog() {
	[ ! -e "$HOME/.dailylog" ] && mkdir "$HOME/.dailylog"
	"$EDITOR" "$HOME/.dailylog/$(date +%d_%m_%y)"
}

git_config_change_user_credentials() {
	printf "Change name and email for current commit?\n"
	for _option in user.name user.email; do
		printf "git config --get ${_option} => "
		git config --get "${_option}"
		read -p "Change ${_option} (y/n/q)? " y_n_q
		msg="option selected"
		case "$y_n_q" in
			y|Y|Yes|yes ) echo "'${y_n_q}' $msg'"; git_change_user_info "${_option}";;
			n|N|No|no ) echo "'${y_n_q}' $msg, skipping";;
			q|Q|Quit|quit ) echo "'${y_n_q}' $msg, quitting"; break;;
			* ) echo "invalid option... quitting";;
		esac
	done
}

search_history() {
	edit_history $HOME/.bash_eternal_history | \
		python -c "import re,sys;\
		print(\
			''.join(\
				[\
				'{}   '.format(line.rstrip()) \
				if re.match('^\#[0-9]{4,4}\-[0-9]{2,2}\-[0-9]{2,2} [0-9]{2,2}:[0-9]{2,2}:[0-9]{2,2}', line) \
				else '{}\n'.format(line.rstrip()) \
				for line in sys.stdin.readlines()\
				]\
			)\
		)" | grep -P "^\#[0-9]{4,4}\-[0-9]{2,2}\-[0-9]{2,2} "
}

python_find_files() {
	"$EDITOR" -O $(find . -iname "*.py" | fzf | tr '\n' ' ') 2>/dev/null
}

rm_pyshit() {
	# Remove local temp files that add unneeded information to a repository
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	rm -r build *.egg-info
}

find_windows_home() {
	# for WSL
	IFS=':' read -a fields <<<"$PATH"
	for field in "${fields[@]}"; do
		if [[ $field =~ ^(/mnt/.*)/AppData/Local/.* ]]; then
			echo ${BASH_REMATCH[1]}
			exit
		fi
	done
}

trollface1() {
	# Ascii art from https://copypastatext.com/trollface/
	printf "
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣠⣤⣤⣤⠴⠶⠶⠶⠶⠒⠾⠿⠿⠿⣛⡛⠛⠛⠛⠛⠛⠻⠿⡷⠶⠶⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣤⡾⠟⠛⠉⣉⣩⣤⡴⠦⠭⠥⠒⠒⠒⠒⠒⠒⠒⠒⠂⠤⠀⢀⣀⠈⠑⠢⢀⠑⠀⠀⠙⢿⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⡾⠟⠁⣠⡢⠔⢫⠞⣉⣀⡀⠀⠀⠀⠐⠒⠄⠠⠀⠀⠐⡠⢂⡴⠶⠦⢴⡊⠙⠒⠀⠑⠀⠀⠀⠀⠹⣧⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⣿⠀⡠⢊⡫⡀⢀⣤⣞⣡⣼⣿⣦⠀⠐⠉⠱⡤⢢⠦⠀⠀⣰⠋⣀⣤⣴⣿⣿⣆⠀⠀⠀⠀⠀⠀⠙⠳⢾⣷⡀⠀⠀⠀⠀⠀
⠀⠀⠀⣼⡏⣰⠁⠠⠪⠿⣟⠩⠉⠀⠀⠈⢻⡧⠄⣴⠞⠁⣣⠖⠀⢰⣧⠞⠁⠀⠠⠍⡻⣼⡆⠀⢀⣀⡀⠀⠀⠀⠀⠙⣧⡀⠀⠀⠀⠀
⠀⣴⡾⠟⣽⢋⡒⠦⡢⠐⠀⠄⠒⠲⠶⠖⠋⠀⢸⡇⠀⠀⠙⠀⠀⠘⣷⡀⠤⠤⠀⠀⠀⠉⠛⠻⡍⠀⠐⠉⣉⣗⠦⣄⠘⢿⣦⡀⠀⠀
⣾⠋⠀⢸⠇⢹⠟⢦⣄⡀⠄⠀⠀⠉⠁⣰⠶⢖⣾⠁⠀⠀⠀⠐⠒⢦⣤⣝⠓⠒⠒⠊⠀⠈⠀⠀⢀⣴⠞⠋⣽⢻⠱⡈⢳⡈⢯⠻⣦⠀
⣿⠀⡆⠸⣆⢸⡦⡄⠉⠛⠶⣬⣔⡀⠘⠁⢸⡏⠁⠀⠀⠶⢦⣤⡀⠈⡇⠈⠳⠄⠀⢀⠀⠀⣀⡴⢿⠥⣄⣼⠃⡌⠀⢳⠀⢳⠸⡄⠘⣧
⣿⡀⡇⠀⠈⠷⣇⡗⣦⣠⡀⠈⠙⠛⡿⠶⠾⢿⣶⣶⣶⣶⣀⣀⣁⣀⣁⣀⣠⣤⣿⠿⠟⠛⣉⣀⡏⢀⡿⠁⠰⠀⠀⢸⠀⠀⠀⡇⠀⣿
⠘⣷⡁⢀⢸⠀⣿⠀⡟⠀⣷⠋⢳⡾⠙⢷⡀⠀⣠⠤⣌⠉⠉⣉⣭⣍⠉⣩⠭⢤⣀⡴⠚⢲⡇⠀⣿⠏⠀⠠⠃⠀⠀⣸⠀⠀⠀⠁⣼⠏
⠀⠘⣷⢸⠈⡆⣿⣿⣁⢀⠏⠀⢸⡇⠀⠀⢻⣾⠁⠀⠈⢳⣴⠏⠀⠹⣶⠇⠀⠀⢹⡀⣀⣼⣷⡾⠃⢠⠀⢀⠄⠀⠠⠁⠀⠀⣀⣼⠋⠀
⠀⠀⢸⣿⠀⡇⣿⣿⣿⣿⣤⣄⣼⠃⠀⠀⢸⡟⠀⠀⠀⠀⣿⠀⠀⠀⣿⡀⠀⢀⣿⣿⣿⣿⡟⠁⢠⠃⠀⠀⠀⡀⠀⠀⢀⣼⠟⠁⠀⠀
⠀⠀⢸⣿⠀⡇⣿⣿⣿⣿⣿⣿⣿⣷⣶⣦⣿⣧⣀⣀⣤⣤⣿⣶⣶⣶⣿⣿⣿⣿⣿⣿⡿⣫⠄⢀⠂⠀⠀⠀⠀⡄⠀⢠⣿⠁⠀⠀⠀⠀
⠀⠀⢸⣿⠀⣧⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣩⠞⠁⡰⠁⠀⠠⠀⠀⡐⠀⢠⡾⠃⠀⠀⠀⠀⠀
⠀⠀⢸⡇⠀⣿⡟⢀⡟⠀⣿⠋⢻⡿⠻⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢁⡔⠁⠠⠞⠀⠀⠀⠁⢀⠌⢀⣴⠟⠁⠀⠀⠀⠀⠀⠀
⠀⠀⣼⠃⡄⢹⣿⡙⢇⣠⡇⠀⣸⠁⢠⠇⠀⢹⠃⢠⠛⠙⡏⠉⣇⣼⠿⢃⡴⠋⠀⠐⠁⠔⠀⠐⠁⣠⣢⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠀⡇⠸⡿⢷⣄⡀⠙⠒⠳⡤⠼⣄⣀⢼⣀⢾⣀⣸⣶⡾⠟⣁⡴⠋⢀⡠⠒⠁⠀⠀⢀⣤⡾⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠀⠻⡄⠉⠠⡉⠙⠳⠶⣶⣶⣶⣾⣷⣶⠿⠿⠟⠋⠉⠖⠫⠕⠒⠈⠀⢀⣤⣴⡶⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢿⡄⠀⠉⠓⠀⠀⠈⠉⠠⠌⠀⠀⠀⣀⠠⠄⠂⠠⠤⠤⠴⠊⠁⣀⣴⡾⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠻⣦⣑⠒⠤⣅⣀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣶⠶⠶⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠙⠛⠶⠶⣤⣭⣭⣭⣭⣴⠶⠶⠛⠛⠉⠉"
}

trollface2() {
	# Ascii art from https://copypastatext.com/trollface/
	printf "
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⡴⠶⠶⠶⠶⠶⠶⠶⠶⢶⣦⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡴⠶⠛⠋⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠙⠛⠷⠶⢦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣠⠞⠉⠀⠀⠀⢀⠀⠀⠒⠀⠀⠀⠀⠀⠒⠒⠐⠒⢒⡀⠈⠀⠀⠀⠀⡀⠒⠀⢀⠀⠀⠀⠈⠛⣦⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣾⠋⠀⠀⢀⠀⢊⠥⢐⠈⠁⠀⠀⠀⢀⠀⠀⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠈⢑⠠⢉⠂⢀⠀⠀⠈⢷⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣼⠃⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⠀⠈⠀⠁⠀⠀⠀⠀⠈⢷⡀⠀⠀⠀⠀
⠀⠀⠀⣠⣾⠃⠀⠀⠀⠀⠀⠀⣠⠶⠛⣉⣩⣽⣟⠳⢶⣄⠀⠀⠀⠀⠀⠀⣠⡶⠛⣻⣿⣯⣉⣙⠳⣆⠀⠀⠀⠀⠀⠀⠈⣷⣄⠀⠀⠀
⠀⣠⠞⠋⠀⢁⣤⣤⣤⣌⡁⠀⠛⠛⠉⣉⡍⠙⠛⠶⣤⠿⠀⢸⠀⠀⡇⠀⠻⠶⠞⠛⠉⠩⣍⡉⠉⠋⠀⣈⣤⡤⠤⢤⣄⠀⠈⠳⣄⠀
⢰⡏⠀⠀⣴⠋⠀⢀⣆⠉⠛⠓⠒⠖⠚⠋⠀⠀⠀⠀⠀⠀⠀⡾⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⠈⠛⠒⠒⠛⠛⠉⣰⣆⠀⠈⢷⡀⠀⠘⡇
⢸⡇⠀⠀⣧⢠⡴⣿⠉⠛⢶⣤⣀⡀⠀⠠⠤⠤⠄⣶⠒⠂⠀⠀⠀⠀⢀⣀⣘⠛⣷⠀⠀⠀⠀⠀⢀⣠⣴⠶⠛⠉⣿⠷⠤⣸⠃⠀⢀⡟
⠈⢷⡀⠄⠘⠀⠀⠸⣷⣄⡀⠈⣿⠛⠻⠶⢤⣄⣀⡻⠆⠋⠉⠉⠀⠀⠉⠉⠉⠐⣛⣀⣤⡴⠶⠛⠋⣿⠀⣀⣠⣾⠇⠀⠀⠋⠠⢁⡾⠃
⠀⠀⠙⢶⡀⠀⠀⠀⠘⢿⡙⠻⣿⣷⣤⣀⡀⠀⣿⠛⠛⠳⠶⠦⣴⠶⠶⠶⠛⠛⠋⢿⡀⣀⣠⣤⣾⣿⠟⢉⡿⠃⠀⠀⠀⢀⡾⠋⠀⠀
⠀⠀⠀⠈⢻⡄⠀⠀⠀⠈⠻⣤⣼⠉⠙⠻⠿⣿⣿⣤⣤⣤⣀⣀⣿⡀⣀⣀⣠⣤⣶⣾⣿⠿⠛⠋⠁⢿⣴⠟⠁⠀⠀⠀⢠⡟⠁⠀⠀⠀
⠀⠀⠀⠀⠀⢷⡄⠀⠀⠀⠀⠙⠿⣦⡀⠀⠀⣼⠃⠉⠉⠛⠛⠛⣿⡟⠛⠛⠛⠉⠉⠉⢿⡀⠀⣀⣴⠟⠋⠀⠀⠀⠀⢠⡾⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠙⢦⣀⠀⣀⠀⠀⡈⠛⠷⣾⣇⣀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⢀⣀⣼⡷⠾⠋⢁⠀⢀⡀⠀⣀⡴⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⣦⣉⠒⠬⣑⠂⢄⡉⠙⠛⠛⠶⠶⠶⠾⠷⠶⠚⠛⠛⠛⠉⣁⠤⢐⡨⠤⢒⣩⡴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠶⣤⣉⠀⠂⠥⠀⠀⠤⠀⠀⠀⠀⠀⠤⠄⠀⠠⠌⠂⢈⣡⡴⠖⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡴⠞⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠳⠶⠶⠶⠶⠶⠖⠛⠋⠁"
}
# >>> Functions without args. >>>

# <<< Functions with args. <<<
docker_rm_stop() {
	docker stop $1
	docker rm $1
}

venv() {
	# Useful to use this rather than remembering the flags
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
	read -p "new $_option: " value
	git config --local "$_option" "$value" && echo "successfuly changed" \
		|| echo "unsuccessful"
}

settitle() {
	# https://stackoverflow.com/questions/40234553/how-to-rename-a-pane-in-tmux
	export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
	echo -ne "\e]0;$1\a"
}

env_add() {
	# add a python env
	local env="$1"
	python -m ipykernel install --user --name="$env"
}

make_python_library() {
    local library_name="$1"
    if [ ! -z "$library_name" ]; then
        library_name_underscore="${1//-/_}"

        mkdir "$library_name"
        pushd "$library_name"

        mkdir "$library_name_underscore"
        touch "$library_name_underscore/__init__.py"

        # setup.py boilerplate
        cat << EOF >> setup.py
from setuptools import setup, find_packages

setup(
    name="$library_name_underscore",
    packages=find_packages(
        exclude=["tests*"],
    ),
    version="0.1.0",
    description="",
    author="",
    python_requires=">=3.7",  # 3.7 for typing
    install_requires=[
    ],
    extras_require={
        "tests": ["pytest"],
    },
    entry_points={
        "console_scripts": [
            "$library_name_underscore=$library_name_underscore.cli:main",
        ],
    },
)
EOF
        # cli.py boilerplate
        cat << EOF >> $library_name_underscore/cli.py
import argparse

def get_args():
    parser = argparse.ArgumentParser(description="")
    args = parser.parse_args()
    return args

def main():
    args = get_args()
    pass

if __name__ == "__main__":
    main()
EOF

        # tests for pytest boilerplate
        mkdir tests
        touch ./tests/__init__.py
        mkdir ./tests/fixtures
        # scaffold for test fixures imports
        cat << EOF >> "./tests/fixtures/__init__.py"
import os
from pathlib import Path

import pytest
TEST_FIXTURES = Path(os.path.dirname(__file__))
#EXAMPLE_FIXTURE= TEST_FIXTURES / \"example.txt\"
EOF
        popd
    else
        printf "No library name provided!\nPlease Provide a name for the new library.\nExiting.\n"
    fi
}
# >>> Functions with args. >>>
