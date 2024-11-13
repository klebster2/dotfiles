#!/bin/bash

# Simple conda completion script for bash
_conda_env_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local cmd=${COMP_WORDS[1]}

    if [[ ${COMP_WORDS} != "conda" && ${COMP_WORDS} != "mamba" ]]; then
        return
    fi

    # Only complete for 'conda activate' command
    if [[ ${COMP_WORDS[0]} == $cur && $cmd == "" ]]; then
        local opts=$(conda --help | grep -P "^ *COMMAND" -A100 | tail -n+2 | cut -d ' ' -f5 | grep -v '^$')
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
    elif [[ ${COMP_WORDS[0]} == $cur && $cmd == "activate" ]]; then
        # Get list of environments, excluding base environment
        local envs=$(conda env list --json 2> /dev/null | jq .envs[] -r | tail -n+2 | xargs -I{} basename {})
        COMPREPLY=($(compgen -W "$envs" -- "$cur"))
    elif [[ ${COMP_WORDS[0]} == $cur && $cmd == "deactivate" ]]; then
        # Get list of environments, excluding base environment
        local envs=$(conda env list --json 2> /dev/null | jq .envs[] -r | tail -n+2 | xargs -I{} basename {})
        COMPREPLY=($(compgen -W "$envs" -- "$cur"))
    elif [[ ${COMP_WORDS[0]} == $cur  && $cmd == "remove" ]]; then
        # Get list of environments, excluding base environment
        local envs=$(conda env list --json 2> /dev/null | jq .envs[] -r | tail -n+2 | xargs -I{} basename {})
        COMPREPLY=($(compgen -W "$envs" -- "$cur"))
    elif [[ ${COMP_WORDS[0]} == $cur && $cmd == "create" ]]; then
        # Get create options
        local opts=$(conda create --help | grep usage | sed -r 's/usage: conda create |[A-Z|]+//g' | tr -d [ | tr -d ])
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
    elif [[ ${COMP_WORDS[0]} == $cur && $cmd != "" ]]; then
        while IFS= read -r line; do
            if grep -Pqv "^ *$line" <<< "$cmd"; then
                opts="$opts $line"
            fi
        done< <(conda --help | grep -P "^ *COMMAND" -A1000 | tail -n+2 | cut -d ' ' -f5 | grep -v '^$')
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
    fi
}

# Register the completion function
complete -F _conda_env_completion conda

# Optionally, you might want to add completion for mamba if you use it
if command -v mamba &> /dev/null; then
    complete -F _conda_env_completion mamba
fi
