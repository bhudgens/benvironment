#! /usr/bin/env bash

return
#############################################################################
# Software Install
#############################################################################

if [ ! -d "$HOME/.vim/autoload/plug.vim"]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +'PlugInstall --sync' +qa
fi
