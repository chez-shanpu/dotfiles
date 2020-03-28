#!/bin/bash
DOTFILES_ROOT=$PWD

ln -fs ${DOTFILES＿ROOT}/.gitconfig ~
ln -fs ${DOTFILES＿ROOT}/.tmux.conf ~

mkdir -p ~/.config/fish
ln -fs ${DOTFILES＿ROOT}/.config/fish/config.fish ~/.config/fish/
ln -fs ${DOTFILES＿ROOT}/.config/fish/fish_variables ~/.config/fish/
ln -fs ${DOTFILES＿ROOT}/.config/fish/fishfile ~/.config/fish/

mkdir -p ~/.config/nvim
ln -fs ${DOTFILES＿ROOT}/.config/nvim/dein.toml ~/.config/nvim
ln -fs ${DOTFILES＿ROOT}/.config/nvim/dein_lazy.toml ~/.config/nvim
ln -fs ${DOTFILES＿ROOT}/.config/nvim/init.vim ~/.config/nvim

mkdir -p ~/.config/powerline
cp -r ${DOTFILES＿ROOT}/.config/powerline ~/.config/powerline