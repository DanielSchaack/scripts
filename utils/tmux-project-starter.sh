#!/usr/bin/bash
hidden=""

setup_python(){
    if [[ ! -d "./venv" ]]; then
        tmux send-keys -t "python -m venv venv" C-m
    fi
    tmux send-keys -t "source venv/bin/activate" C-m
}

selected=`fd --type d --follow $hidden . $HOME | fzf`

echo "Directory as project to start: $selected"
path_without_slash="${selected%/}" # remove last slash
last_directory="${path_without_slash##*/}" # remove all until last path slash

tmux has-session -t $last_directory 2>/dev/null

if [[ $? != 0 ]]; then # if no session with dir name
    tmux new-session -d -s $last_directory -n "editor"
    tmux send-keys -t $last_directory:editor "cd $selected" C-m

    tmux send-keys -t $last_directory:editor "tmux split-window -h -p 25" C-m
    if [[ "$is_python" == "true" ]]; then
        setup_python
    fi
    tmux select-pane -t 0

    if [[ "$is_python" == "true" ]]; then
        setup_python
    fi
    tmux send-keys -t $last_directory:editor "nvim ." C-m

    tmux select-window -t $last_directory:editor
fi

if [[ -z "$TMUX" ]]; then
    tmux attach-session -t $last_directory
else
    tmux switch-client -t $last_directory
fi
