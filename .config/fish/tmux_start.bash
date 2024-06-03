#!/bin/bash

# Check if a tmux session already exists
tmux has-session -t mysession 2>/dev/null

if [ $? != 0 ]; then
    # Create a new tmux session named "mysession" if it doesn't exist
    tmux new-session -d -s mysession
fi

# Attach to the existing or newly created tmux session
tmux attach-session -t mysession