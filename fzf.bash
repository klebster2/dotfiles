# Setup fzf
# ---------
if [[ ! "$PATH" == */home/kleber/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/kleber/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/kleber/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/kleber/.fzf/shell/key-bindings.bash"
