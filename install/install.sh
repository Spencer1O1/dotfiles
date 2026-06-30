#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

echo "Installing Linux/WSL dotfiles..."

if [ ! -d "$DOTFILES" ]; then
  echo "ERROR: $DOTFILES does not exist."
  echo "Clone your dotfiles repo to ~/dotfiles first."
  exit 1
fi

echo
echo "Creating ~/.config..."
mkdir -p "$HOME/.config"

echo "Linking Neovim config..."
if [ -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
  rm -rf "$HOME/.config/nvim"
fi

ln -s "$DOTFILES/nvim" "$HOME/.config/nvim"

echo
echo "Creating ~/.local/bin..."
mkdir -p "$HOME/.local/bin"

echo "Linking dotfiles scripts..."
if [ -e "$HOME/.local/bin/dotfiles" ] || [ -L "$HOME/.local/bin/dotfiles" ]; then
  rm -f "$HOME/.local/bin/dotfiles"
fi

ln -s "$DOTFILES/scripts/linux/dotfiles" "$HOME/.local/bin/dotfiles"
chmod +x "$DOTFILES/scripts/linux/dotfiles"

echo
echo "Ensuring ~/.bashrc sources dotfiles bash config..."
BASH_SOURCE_BLOCK='
# Load dotfiles bash config
if [ -f "$HOME/dotfiles/bash/bashrc" ]; then
  source "$HOME/dotfiles/bash/bashrc"
fi'

if ! grep -q 'source "$HOME/dotfiles/bash/bashrc"' "$HOME/.bashrc"; then
  printf "%s\n" "$BASH_SOURCE_BLOCK" >> "$HOME/.bashrc"
fi

echo
echo "Done."
echo "Reload your shell with:"
echo "  source ~/.bashrc"
