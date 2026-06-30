Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Pulling Windows dotfiles..."
Set-Location "$HOME\dotfiles"
git restore nvim/lazy-lock.json 2>$null
git pull

Write-Host ""
Write-Host "Pulling WSL dotfiles..."
wsl.exe bash -lc "cd ~/dotfiles && git restore nvim/lazy-lock.json 2>/dev/null || true && git pull"

Write-Host ""
Write-Host "Done."
