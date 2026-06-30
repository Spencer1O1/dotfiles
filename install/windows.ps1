Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Dotfiles = Join-Path $HOME "dotfiles"

Write-Host "Installing Windows dotfiles..."

if (!(Test-Path $Dotfiles)) {
  Write-Host "ERROR: $Dotfiles does not exist."
  Write-Host "Clone your dotfiles repo to $HOME\dotfiles first."
  exit 1
}

Write-Host ""
Write-Host "Linking Neovim config..."

$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$nvimSource = Join-Path $Dotfiles "nvim"

if (Test-Path $nvimTarget) {
  Remove-Item $nvimTarget -Recurse -Force
}

cmd /c mklink /J "$nvimTarget" "$nvimSource" | Out-Null

Write-Host ""
Write-Host "Creating ~/bin..."

$binPath = Join-Path $HOME "bin"
New-Item -ItemType Directory -Path $binPath -Force | Out-Null

Write-Host "Installing dotfiles script..."

$cmdSource = Join-Path $Dotfiles "scripts\windows\dotfiles.cmd"
$cmdTarget = Join-Path $binPath "dotfiles.cmd"

if (Test-Path $cmdTarget) {
  Remove-Item $cmdTarget -Force
}

Copy-Item $cmdSource $cmdTarget -Force

Write-Host ""
Write-Host "Adding ~/bin to user PATH if needed..."

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($null -eq $userPath) {
  $userPath = ""
}

$binAlreadyInPath = $userPath.Split(";") -contains $binPath

if (-not $binAlreadyInPath) {
  $newPath = if ($userPath.Length -gt 0) {
    "$userPath;$binPath"
  }
  else {
    "$binPath"
  }

  [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
  Write-Host "Added $binPath to user PATH."
}
else {
  Write-Host "$binPath is already in user PATH."
}

Write-Host ""
Write-Host "Installing PowerShell profile..."

$profileSource = Join-Path $Dotfiles "pwsh\Microsoft.PowerShell_profile.ps1"
$profileTarget = $PROFILE
$profileDir = Split-Path $profileTarget

New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

if (Test-Path $profileTarget) {
  Remove-Item $profileTarget -Force
}

Copy-Item $profileSource $profileTarget -Force

Write-Host ""
Write-Host "Done."
Write-Host "Close and reopen PowerShell / Windows Terminal."
Write-Host "Then test:"
Write-Host "  dotfiles"
Write-Host "  nvim"
