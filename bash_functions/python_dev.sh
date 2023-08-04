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
