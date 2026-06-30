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

