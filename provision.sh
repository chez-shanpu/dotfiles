#!/bin/bash
DOTFILES_ROOT=$PWD

ln -fs ${DOTFILES_ROOT}/.gitconfig ~
ln -fs ${DOTFILES_ROOT}/.tmux.conf ~

mkdir -p ~/.config/fish
ln -fs ${DOTFILES_ROOT}/.config/fish/config.fish ~/.config/fish/
ln -fs ${DOTFILES_ROOT}/.config/fish/fish_variables ~/.config/fish/
ln -fs ${DOTFILES_ROOT}/.config/fish/fish_plugins ~/.config/fish/

mkdir -p ~/.config/nvim
ln -fs ${DOTFILES_ROOT}/.config/nvim/dein.toml ~/.config/nvim
ln -fs ${DOTFILES_ROOT}/.config/nvim/dein_lazy.toml ~/.config/nvim
ln -fs ${DOTFILES_ROOT}/.config/nvim/init.vim ~/.config/nvim

mkdir -p ~/.config/powerline
cp -r ${DOTFILES_ROOT}/.config/powerline ~/.config/
