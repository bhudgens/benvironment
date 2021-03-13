function ide() {
  if [ -z "$TMUX" ]; then
    # TODO: Need to perform new session stuff
    :
  fi

  tmux split-window -h
  tmux split-window -v
  tmux split-window -h
  tmux select-layout main-horizontal
  tmux resize-pane -D 10
}
