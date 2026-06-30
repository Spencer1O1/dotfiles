## After cloning the repo, in linux:
1. open ~/.bashrc
2. paste the following code at the bottom
```sh
# Load dotfiles bash config
if [ -f "$HOME/dotfiles/bashrc" ]; then
  source "$HOME/dotfiles/bash/bashrc"
fi
```
3. Link the dotfiles script to the local bin folder
```sh
ln -s ~/dotfiles/scripts/linux/dotfiles ~/.local/bin/dotfiles
```
(this assumes that dotfiles is installed at $HOME)

