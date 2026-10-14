
$ErrorActionPreference="Stop"

function OK($m){Write-Host "[OK] $m" -ForegroundColor Green}
function INFO($m){Write-Host "[INFO] $m" -ForegroundColor Cyan}
function WARN($m){Write-Host "[WARN] $m" -ForegroundColor Yellow}

$root = Split-Path $PSScriptRoot -Parent
$hub = Join-Path $root "Codex Hub"

INFO "Checking environment"

$cx = Join-Path $env:USERPROFILE ".codex"
$ds = Join-Path $env:USERPROFILE ".codex-deepseek"

if(!(Test-Path $cx)){
    New-Item -ItemType Directory -Path $cx | Out-Null
}
if(!(Test-Path $ds)){
    New-Item -ItemType Directory -Path $ds | Out-Null
}

OK "CX interface directory ready"
OK "DS interface directory ready"

$desktop=[Environment]::GetFolderPath("Desktop")

function Create-Link($name,$target){
    $shell=New-Object -ComObject WScript.Shell
    $link=$shell.CreateShortcut("$desktop\$name.lnk")
    $link.TargetPath="powershell.exe"
    $link.Arguments="-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$target`""
    $link.WorkingDirectory=(Split-Path $target)
    $link.Save()
}

$plus="$hub\scripts\Start-Codex-Plus.ps1"
$deep="$hub\scripts\Start-Codex-DeepSeek.ps1"

if(Test-Path $plus){
    Create-Link "Codex Plus" $plus
    OK "Codex Plus shortcut created"
}else{
    WARN "Start-Codex-Plus.ps1 missing"
}

if(Test-Path $deep){
    Create-Link "Codex DeepSeek" $deep
    OK "Codex DeepSeek shortcut created"
}else{
    WARN "Start-Codex-DeepSeek.ps1 missing"
}

if(Test-Path "$hub\codex-hub.exe"){
    OK "CodexHub executable ready"
}else{
    WARN "codex-hub.exe missing"
}

OK "Setup finished"
