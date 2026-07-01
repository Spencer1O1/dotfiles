function wsld {
  wsl.exe --cd "~"
}
  
# Replace winget -> apt for fun
function apt {
  winget @args
}
# Also have to replace winget for "sudo apt"
function sudo {
  if ($args[0] -eq "apt") {
    sudo.exe winget @($args[1..($args.Count - 1)])
  }
  else {
    sudo.exe @args
  }
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
  $homePath = $HOME.TrimEnd("\")
  $systemDrive = $env:SystemDrive.TrimEnd(":").ToLower()

  if ($path.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
    $path = "~" + $path.Substring($homePath.Length)
  }
  elseif ($path -match "^([A-Za-z]):\\?(.*)$") {
    $drive = $matches[1].ToLower()
    $rest = $matches[2]

    if ($drive -eq $systemDrive) {
      if ($rest.Length -gt 0) {
        $path = "/" + $rest
      }
      else {
        $path = "/"
      }
    }
    else {
      if ($rest.Length -gt 0) {
        $path = "/mnt/$drive/$rest"
      }
      else {
        $path = "/mnt/$drive"
      }
    }
  }

  $path = $path.Replace("\", "/")

  Write-Host "$user@$promptHost" -ForegroundColor Green -NoNewline
  Write-Host ":" -ForegroundColor White -NoNewline
  Write-Host "$path" -ForegroundColor Blue -NoNewline
  Write-Host "$" -ForegroundColor White -NoNewline

  [Console]::ResetColor()
  return " "
}

# Ctrl+F for ghost text
Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Alt+f -Function AcceptNextSuggestionWord

# Alt+. for autocomplete menu (Ctrl+. doesn't reach apps on Windows; matches Neovim)
Set-PSReadLineKeyHandler -Chord 'Ctrl+.' -Function MenuComplete
