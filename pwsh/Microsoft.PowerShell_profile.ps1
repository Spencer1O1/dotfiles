function wsld {
  wsl.exe --cd "~"
}

function apt {
  winget @args
}

function apt-update {
  winget source update
}

function apt-upgrade {
  winget upgrade --all
}

function prompt {
  $user = $env:USERNAME.ToLower()

  $promptHost = $env:COMPUTERNAME.ToLower()
  if ($promptHost -eq "esecoso") {
    $promptHost = "windows"
  }

  $path = (Get-Location).Path

  if ($path.StartsWith($HOME)) {
    $path = "~" + $path.Substring($HOME.Length)
  }
  elseif ($path -match "^([A-Za-z]):\\(.*)$") {
    $drive = $matches[1].ToLower()
    $rest = $matches[2]
    $path = "/mnt/$drive/$rest"
  }

  $path = $path.Replace("\", "/")

  Write-Host "$user@$promptHost" -ForegroundColor Green -NoNewline
  Write-Host ":" -ForegroundColor White -NoNewline
  Write-Host "$path" -ForegroundColor Blue -NoNewline
  Write-Host "$" -ForegroundColor White -NoNewline

  [Console]::ResetColor()
  return " "
}

Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Alt+f -Function AcceptNextSuggestionWord
