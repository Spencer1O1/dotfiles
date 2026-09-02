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
Write-Host "Updating PowerShell profile..."
$profileSource = Join-Path $HOME "dotfiles\pwsh\Microsoft.PowerShell_profile.ps1"
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
Copy-Item $profileSource $PROFILE -Force

Write-Host ""
Write-Host "Done."
