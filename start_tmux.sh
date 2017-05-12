tmux new-session -d -s argbash -c src 'vim stuff.m4'
tmux new-window -c resources
tmux new-window -c tests
tmux select-window -t argbash:0
tmux -2 attach-session -t argbash
