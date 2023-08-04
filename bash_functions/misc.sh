#!/bin/bash
# >>> Functions without args - can be used in bash pipeline >>>
zombies() {
	# find zombie prcs - `killall $(zombies | tr '\n' ' ')` kills all zombies
	for pid in $(ps axo pid=,stat= | awk '$2~/^Z/ { print $1 }') ; do
		echo "$pid"
	done
}

dailylog() {
	[ ! -e "$HOME/.dailylog" ] && mkdir "$HOME/.dailylog"
	"$EDITOR" "$HOME/.dailylog/$(date +%d_%m_%y)"
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

trollfaces() {
    curl "https://copypastatext.com/trollface/" | grep -Pzo '<code1>(\n|.)*?</code1>'
}
# >>> Functions without args. >>>

# <<< Functions with args. <<<
findbashfunctions() {
	# meta function
	for file in $@; do
		grep -P "^(function )?[a-zA-Z]\w+\(\) {" "$file" \
			| sed -r 's/\(\).*$//g'
	done
}

win2linux_path() {
	# ensure arg is quoted e.g.
	# $ echo "C:\Users\KleberNoel\Downloads" | sed -e 's|\\|/|g;s|C:|/mnt/c|'
	# /mnt/c/Users/KleberNoel/Downloads
	if [ "$#" -eq 0 ]; then
		echo "No args provided to function. Exiting."
		exit 1
	elif [ "$#" -gt 1 ]; then
		echo "More than one arg provided to function. Ensure paths with spaces are enclosed by quotes. Exiting"
		exit 1
	else
		echo "$1" | sed -re 's|\\|/|g;s|^[C-Z]:|/mnt/c|'
	fi
}

docker_rm_stop() {
	docker stop $1
	docker rm $1
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
	perl -pe 'use POSIX qw(strftime); s/^#(\d+)/strftime "#%F %H:%M:%S", localtime($1)/e' "$1"
}

bakswp() {
	# Simple helper for a common routine (switch backup file with focused file)
	[ -e "$1.bak2" ] || [ -e "$1.bak" ] && exit 0
	cp $1{,.bak2}
	cp $1{.bak,}
	mv $1{.bak2,.bak}
}

disksp() {
	du $@ -Sh | sort -n -r | more
}

settitle() {
	# https://stackoverflow.com/questions/40234553/how-to-rename-a-pane-in-tmux
	export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
	echo -ne "\e]0;$1\a"
}
# >>> Functions with args. >>>
