## Neovim cheat sheet

A landscape PDF of the Neovim keybinds, in the same style as the secure-vim packet:

```
python3 -m pip install reportlab
python3 ~/dotfiles/scripts/build_nvim_cheatsheet.py
```

Writes `output/pdf/nvim-cheatsheet.pdf`.

## Linux / WSL Setup
```
cd ~
git clone https://github.com/YOUR_USERNAME/dotfiles.git dotfiles
chmod +x ~/dotfiles/install/linux.sh
~/dotfiles/install/linux.sh
source ~/.bashrc
```

## Windows Setup
```
cd $HOME
git clone https://github.com/YOUR_USERNAME/dotfiles.git dotfiles
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\install\windows.ps1
```

