if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

ta() {
  local sessions
  sessions=$(tmux list-sessions 2>/dev/null)
  if [ -z "$sessions" ]; then
    tmux new-session
  else
    local target
    target=$(echo "$sessions" | fzf --height 40% --reverse | cut -d: -f1)
    [ -n "$target" ] && tmux attach -t "$target"
  fi
}

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
