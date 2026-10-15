param([switch]$CheckOnly, [string]$ProfileRoot = $env:USERPROFILE)
$ErrorActionPreference = 'Stop'
$tools = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'tools'
. (Join-Path $tools 'Hub.Common.ps1')
$previous = $env:CODEX_HOME
try {
    $paths = Get-HubPaths $ProfileRoot
    if (-not (Test-Path -LiteralPath $paths.Settings) -or -not (Test-Path -LiteralPath $paths.Config)) {
        if ($CheckOnly) { throw 'DS 尚未配置，请运行 Configure-DeepSeek.cmd。' }
        & (Join-Path $tools 'Configure-DeepSeek.ps1') -ProfileRoot $ProfileRoot
    }
    [void](Read-HubSettings $paths)
    [void](Read-HubKey $paths)
    $env:CODEX_HOME = $paths.DeepSeek
    $Host.UI.RawUI.WindowTitle = 'Codex DeepSeek'
    Write-Host ('Codex DeepSeek | CODEX_HOME = ' + $env:CODEX_HOME) -ForegroundColor Green
    $exe = Find-HubCodex
    if ($CheckOnly) { & $exe --version }
    else { & $exe }
    if ($LASTEXITCODE -ne 0) { throw "Codex exited with code $LASTEXITCODE" }
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    if (-not $CheckOnly) { [void](Read-Host '按回车关闭') }
    throw
}
finally { $env:CODEX_HOME = $previous }
