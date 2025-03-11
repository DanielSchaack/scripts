#!/bin/bash

cleanup() {
    deactivate
}

if [ -z "$1" ]; then
    echo "Error: First argument is missing."
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: Second argument is missing."
    exit 1
fi

file_path=$(dirname $(readlink -f $BASH_SOURCE))

source $file_path/venv/bin/activate
while read input; do
    python3 -u $file_path/ollama_generate.py "$1" "$2" "$input"
done
cleanup

