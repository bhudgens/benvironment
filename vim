#! /usr/bin/env bash

#############################################################################
# Software Install
#############################################################################

apt_get_install () {
  if ! which "$1" > /dev/null; then
    [ -z "${RUN_ONCE}" ] && sudo apt-get update -y && RUN_ONCE=true
    sudo apt-get install -y $1
  fi
}

vimrc_after () {
cat << EOF >> $1
let g:onedark_color_overrides = {
\ "black": {"gui": "#000000", "cterm": "000", "cterm16": "0" },
\ "purple": { "gui": "#C678DF", "cterm": "170", "cterm16": "5" }
\}

colorscheme onedark

set modeline
set modelines=5

filetype plugin indent on
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
EOF
}

apt_get_install rake

if [ ! -d "${HOME}/.vim" ]; then
  curl -L 'https://bit.ly/janus-bootstrap' | bash
fi

if [ ! -d "${HOME}/.vim/janus/vim/colors/onedark" ]; then
  git clone 'https://github.com/joshdick/onedark.vim.git' "${HOME}/.vim/janus/vim/colors/onedark"
fi

if [ ! -f "${HOME}/.vimrc.after" ]; then
  vimrc_after "${HOME}/.vimrc.after"
fi

if [ ! -d "${HOME}/.janus" ] && [ -d "${HOME}/Dropbox/syncstuff/.janus/" ]; then
  rsync -rav -P "${HOME}/Dropbox/syncstuff/.janus/" "${HOME}/.janus/"
fi

set -o vi
