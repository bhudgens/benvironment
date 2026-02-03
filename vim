#! /usr/bin/env bash

#############################################################################
# Get around chicken and egg problem
# 
# Install temp .vimrc to get plugins installed before we install
# full .vimrc that references those plugins and sometimes breaks
# during an install because things like the normal .vimrc cannot
# find our colorscheme
#############################################################################

function _install_temp_vimrc () {
if [ -f "${HOME}/.vimrc" ]; then
  mv "${HOME}/.vimrc" "${HOME}/.vimrc.$$"
fi
cat <<'EOF' > "${HOME}/.vimrc"
call plug#begin('~/.vim/plugged')

" (coc.nvim) Intellesense
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" (tmux-navigator) Navigation Help
Plug 'christoomey/vim-tmux-navigator'

" (NerdTree) File Explorer
Plug 'preservim/nerdtree' |
  \ Plug 'ryanoasis/vim-devicons' |
  \ Plug 'Xuyuanp/nerdtree-git-plugin' |
  \ Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plug 'scrooloose/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'

" (unimpaired) VIM Bindings
Plug 'tpope/vim-unimpaired'

" (surround) Change surrounding chars (changeme) to 'changeme'
Plug 'tpope/vim-surround'

Plug 'bhudgens/vim-format-js'

" (fzf) Search
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" (gitgutter) Smart Gutter Like VSCode
Plug 'airblade/vim-gitgutter'

" onedark
Plug 'joshdick/onedark.vim'

" (NerdCommenter) Smart Comments
Plug 'scrooloose/nerdcommenter'

" (lighline) Smarter status bar
Plug 'itchyny/lightline.vim'

" (vim-visual-multi) Multiline select
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" (vim-which-key) Displays keys available with leader
Plug 'liuchengxu/vim-which-key'

" (fugitive) Git Integration
Plug 'tpope/vim-fugitive'

call plug#end()
EOF
}
#############################################################################
# Software Install
#############################################################################

apt_get_install vim

# Ensure vim >= 9.0.0438
if _which vim; then
  _vim_ver=$(vim --version | head -1 | grep -oP '\d+\.\d+')
  _vim_patch=$(vim --version | grep -oP 'Included patches: \d+-\K\d+' || echo 0)
  _vim_full="${_vim_ver}.${_vim_patch}"
  _vim_min="9.0.438"

  if [ "$(printf '%s\n' "$_vim_min" "$_vim_full" | sort -V | head -1)" != "$_vim_min" ]; then
    eval "$SUDO add-apt-repository -y ppa:jonathonf/vim"
    eval "$SUDO apt-get update -y"
    eval "DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y vim"
  fi
fi
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  _install_temp_vimrc
  vim +'PlugInstall --sync' +qa
  install_dot_file .vimrc
fi

