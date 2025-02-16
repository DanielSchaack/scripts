#!/usr/bin/bash
hidden=""
dir="$HOME"
py_version=""

usage() {
    echo "Usage: $0 [OPTIONS] [ARGUMENTS...]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  --hidden                Adds hidden directory and files to the search. Careful - 'Pollutes' the search unless ~/.fdignore or $HOME/.config/fd/ignore are setup"
    echo "  -d, --directory         Adjust the starting directory from HOME to the provided one"
    echo "  -p, --python    VERSION Activates venv of chosen directory. Creates one if missing. If a version is provided, use virtualenv to adjust venv to version"
}

setup_python(){
    if [[ ! -z "$1" ]]; then
        tmux send-keys -t $last_directory:editor "virtualenv -p $1 venv; tmux wait -S venv" C-m
        tmux wait venv
    fi
    if [[ ! -d "$selected/venv" ]]; then
        tmux send-keys -t $last_directory:editor "python -m venv venv; tmux wait -S venv" C-m
        tmux wait venv
    fi
    tmux send-keys -t $last_directory:editor "source venv/bin/activate" C-m
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            usage
            exit 0
            ;;
        --hidden)
            hidden="--hidden"
            shift
            ;;
        -d | --directory)
            if [[ ! -z "$2" ]];then
                dir="$2"
            fi
            shift
            shift
            ;;
        -p | --python)
            is_python=true
            if [[ ! -z "$2" ]];then
                py_version="$2"
            fi
            shift
            shift
            ;;
    esac
done

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

    tmux send-keys -t $last_directory:editor.1 "tmux split-window -h -p 25" C-m
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
