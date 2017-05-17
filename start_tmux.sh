tmux new-session -d -s argbash
tmux send-keys 'cd src' C-m
tmux send-keys 'vim stuff.m4' C-m
tmux new-window -c resources
tmux send-keys -l 'make check'
tmux new-window -c tests/regressiontests
tmux send-keys -l 'vim '
tmux select-window -t argbash:0
tmux -2 attach-session -t argbash
