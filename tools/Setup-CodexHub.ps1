param([switch]$NoShortcuts, [switch]$SkipDeepSeek, [string]$ProfileRoot = $env:USERPROFILE)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Hub.Common.ps1')
$root = Split-Path $PSScriptRoot -Parent
$paths = Get-HubPaths $ProfileRoot
$hubExe = Join-Path $root 'Codex Hub\codex-hub.exe'
if (-not (Test-Path -LiteralPath $hubExe)) { throw '缺少 Codex Hub\codex-hub.exe。请完整解压后重试。' }
[void][IO.Directory]::CreateDirectory($paths.Official)
[void][IO.Directory]::CreateDirectory($paths.DeepSeek)
$codex = Find-HubCodex
Assert-HubCodexVersion -Executable $codex -HomePath $paths.DeepSeek
Write-Host ('[OK] Codex CLI：' + $codex) -ForegroundColor Green
Write-Host '[OK] 官方和 DS 使用各自的 CODEX_HOME。' -ForegroundColor Green

if (-not $SkipDeepSeek) {
    $configure = $true
    if ((Test-Path -LiteralPath $paths.Config) -and (Test-Path -LiteralPath $paths.Settings) -and (Test-Path -LiteralPath $paths.Key)) {
        $configure = (Read-Host '已有 DS 配置。是否修改密钥、地址或模型？输入 Y 修改，回车保留') -match '^[Yy]$'
    }
    if ($configure) {
        Write-Host '现在配置 DS；首次输入 API Key，地址和模型可直接回车使用默认值。' -ForegroundColor Cyan
        & (Join-Path $PSScriptRoot 'Configure-DeepSeek.ps1') -ProfileRoot $ProfileRoot
    }
    else { [void](Test-HubDeepSeek $paths) }
}

if (-not $NoShortcuts) {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shell = New-Object -ComObject WScript.Shell
    $psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $links = @(
        @{ Name = 'Codex Hub'; Script = 'tools\Start-CodexHub.ps1'; Hidden = $true },
        @{ Name = 'Codex Plus'; Script = 'Codex Hub\scripts\Start-Codex-Plus.ps1'; Hidden = $false },
        @{ Name = 'Codex DeepSeek'; Script = 'Codex Hub\scripts\Start-Codex-DeepSeek.ps1'; Hidden = $false },
        @{ Name = 'Codex DS 设置'; Script = 'tools\Configure-DeepSeek-Interactive.ps1'; Hidden = $false }
    )
    foreach ($item in $links) {
        $link = $shell.CreateShortcut((Join-Path $desktop ($item.Name + '.lnk')))
        $script = Join-Path $root $item.Script
        $hidden = if ($item.Hidden) { '-WindowStyle Hidden ' } else { '' }
        $link.TargetPath = $psExe
        $link.Arguments = '-NoLogo -NoProfile -ExecutionPolicy Bypass ' + $hidden + '-File "' + $script + '"'
        $link.WorkingDirectory = $paths.ProfileRoot
        $link.IconLocation = $hubExe + ',0'
        $link.Save()
        Write-Host ('[OK] 已创建桌面快捷方式：' + $item.Name) -ForegroundColor Green
    }
}
if ($SkipDeepSeek) { Write-Host 'DS 配置已跳过；使用前请运行 Configure-DeepSeek.cmd。' -ForegroundColor Yellow }
else { Write-Host '[OK] 安装完成。关闭已打开的 Hub，再从桌面 Codex Hub 进入并选择官方或 DeepSeek。' -ForegroundColor Green }
Write-Host '请保留当前解压目录；快捷方式指向本目录。'
