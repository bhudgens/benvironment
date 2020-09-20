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
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  _install_temp_vimrc
  vim +'PlugInstall --sync' +qa
  install_dot_file .vimrc
fi

