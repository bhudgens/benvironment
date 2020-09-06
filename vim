#! /usr/bin/env bash

#############################################################################
# Software Install
#############################################################################

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +'PlugInstall --sync' +qa
fi
