#!/bin/bash
# >>> Functions without args - can possbily be used in bash pipeline >>>
git_config_change_user_credentials() {
	# Quite extraodinarily useful (all you have to do is type `guc' (see `bash_aliases')
	# g - git, u - user, c - credentials
	printf "Change name and email for current commit?\n"
	for _option in user.name user.email; do
		printf "git config --get %s => " "${_option}"
		git config --get "${_option}"
		read -rp "Change ${_option} (y/n/q)? " y_n_q
		msg="option selected"
		case "$y_n_q" in
			y|Y|Yes|yes ) echo "'${y_n_q}' $msg'"; git_change_user_info "${_option}";;
			n|N|No|no ) echo "'${y_n_q}' $msg, skipping";;
			q|Q|Quit|quit ) echo "'${y_n_q}' $msg, quitting"; break;;
			* ) echo "invalid option... quitting";;
		esac
	done
}
git_switch_to_ssh_remote() {
	remote_push="$(git remote -v | cut -d $'\t' -f2 | grep push | cut -d ' ' -f1)"
	if echo "$remote_push" | grep -q ".git"; then
		echo "Error - it seems there is already a .git in the current remote URL:"
		git remote  -v
	else
		git remote set-url origin "git@github.com:$(echo "${remote_push//\/\/}" | cut -d '/' -f2,3).git"
	fi
}
# >>> Functions without args. >>>
# <<< Functions with args. <<<
git_change_user_info() {
	local _option="$1"
	read -rp "new $_option: " value
	git config --local "$_option" "$value" && echo "successfuly changed" \
		|| echo "unsuccessful"
}
# >>> Functions with args. >>>
