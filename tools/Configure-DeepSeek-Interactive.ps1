$ErrorActionPreference = 'Stop'
try { & (Join-Path $PSScriptRoot 'Configure-DeepSeek.ps1') }
catch { Write-Host $_.Exception.Message -ForegroundColor Red; [void](Read-Host '按回车关闭'); exit 1 }
Write-Host '请重新打开 Codex Hub，使新的 DS 配置生效。' -ForegroundColor Green
[void](Read-Host '按回车关闭')
