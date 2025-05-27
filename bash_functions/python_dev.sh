#!/bin/bash

python_find_files() {
    # Use fzf to select, and editor to read
	"$EDITOR" -O $(find . -iname "*.py" | fzf | tr '\n' ' ') 2>/dev/null
}

rm_pyshit() {
	# Remove local temp files that add unneeded information to a repository
    # e.g. __pycache__, .pyc, local build and dist files
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
    [ -d build ] && rm -r build
	[ -d *.egg-info ] && rm -r build
    [ -d dist ] && rm -r dist
}

venv() {
    # Useful to use this rather than remembering the flags. Also see conda create --name (above)
	local python_version="$1"
	dir="./venv"
	[ ! -d "$dir" ] && python$python_version -m venv "$dir"
}

conda_env_create() {
    conda create --name "$1" $@
}

env_add() {
	# add a python env
	local env="$1"
	python -m ipykernel install --user --name="$env"
}

add_current_ipykernel() {
	python -m ipykernel install --user --name="$(conda info | grep "active environment" | cut -d: -f2|tr -d ' ')"
}

isort_cwd_recursive() {
    [ "$1" = "." ] && find . -type f -name '*.py' -exec isort {} \;
    [ -d "$1" ]    && find "$1" -type f -name '*.py' -exec isort {} \;
    [ -f "$1" ]    && isort "$1"
}
