param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Hub.Common.ps1')
try {
    $exe = Find-HubCodex
    $hub = Join-Path (Split-Path $PSScriptRoot -Parent) 'Codex Hub\codex-hub.exe'
    if (-not (Test-Path -LiteralPath $hub)) { throw 'codex-hub.exe is missing.' }
    if ($CheckOnly) { Write-Host ('Hub = ' + $hub); Write-Host ('Codex = ' + $exe); return }
    # Hub starts app-server directly. DS config supplies command-backed auth.
    $previous = $env:CODEX_HUB_CODEX_EXE
    try {
        $env:CODEX_HUB_CODEX_EXE = $exe
        Start-Process -FilePath $hub -WorkingDirectory (Split-Path $hub -Parent) -WindowStyle Normal | Out-Null
    }
    finally { $env:CODEX_HUB_CODEX_EXE = $previous }
}
catch {
    Add-Type -AssemblyName System.Windows.Forms
    [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Codex Hub 启动失败')
    exit 1
}
