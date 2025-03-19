#!/usr/bin/bash
hidden=""
dir="$HOME"
py_version=""

usage() {
    echo "Usage: $0 [-h] [-H] [-d directory] [-p [python_version]]"
    echo "Options:"
    echo "  -h                  Show this help message"
    echo "  -H                  Include hidden directories and files in the search."
    echo "                      (Careful: This may 'pollute' results unless ~/.fdignore or \$HOME/.config/fd/ignore are set up)"
    echo "  -d DIRECTORY        Set the starting directory (default: HOME)"
    echo "  -p                  Activate virtual environment in the chosen directory."
    echo "  -P [VERSION]        Activate virtual environment with the given python version in the chosen directory."
    echo "                      If a version is provided, virtualenv will adjust the venv to that version."
}

while getopts ":hHd:pP::" opt; do
    case ${opt} in
        h ) 
            usage
            exit 0
            ;;
        H )
            hidden="--hidden"
            ;;
        d ) 
            dir="$OPTARG"
            ;;
        p ) 
            is_python=true
            ;;
        P ) 
            is_python=true
            py_version="${OPTARG:-}"
            ;;
        \? ) 
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

setup_python(){
    if [[ ! -d "$selected/venv" ]]; then
        if [[ ! -z "$1" ]]; then
            tmux send-keys -t $last_directory:editor "virtualenv -p $1 venv; tmux wait -S venv" C-m
            tmux wait venv
        else
            tmux send-keys -t $last_directory:editor "python -m venv venv; tmux wait -S venv" C-m
            tmux wait venv
        fi
    fi
    tmux send-keys -t $last_directory:editor "source venv/bin/activate" C-m
}
selected=$(fd --type d --follow $hidden -E .git -E yay . $dir | fzf) || exit

echo "Directory as project to start: $selected"
path_without_slash="${selected%/}" # remove last slash
last_directory="${path_without_slash##*/}" # remove all until last path slash

tmux has-session -t $last_directory 2>/dev/null

if [[ $? != 0 ]]; then # if no session with dir name
    tmux new-session -d -s $last_directory -n "editor"
    tmux send-keys -t $last_directory:editor.1 "cd $selected" C-m
    if [[ "$is_python" == "true" ]]; then
        setup_python $py_version
    fi

    tmux send-keys -t $last_directory:editor.1 "tmux split-window -h -p 25; tmux wait -S pane" C-m
    tmux wait pane
    if [[ "$is_python" == "true" ]]; then
        setup_python
    fi

    tmux select-pane -t 1
    tmux select-window -t $last_directory:editor.1
    tmux send-keys -t $last_directory:editor.1 "nvim ." C-m
fi

if [[ -z "$TMUX" ]]; then
    tmux attach-session -t $last_directory:editor.1
else
    tmux switch-client -t $last_directory
fi
