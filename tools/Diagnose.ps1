param([string]$ProfileRoot = $env:USERPROFILE)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Hub.Common.ps1')
$paths = Get-HubPaths $ProfileRoot
$exe = Find-HubCodex
Write-Host ('Codex executable: ' + $exe)
Assert-HubCodexVersion -Executable $exe -HomePath $paths.DeepSeek
Write-Host ('Official CODEX_HOME: ' + $paths.Official)
Write-Host ('DeepSeek CODEX_HOME: ' + $paths.DeepSeek)
$settings = Read-HubSettings $paths
Write-Host ('DS base URL: ' + $settings.base_url)
Write-Host ('DS model: ' + $settings.model)
foreach ($path in @($paths.Config, $paths.Catalog, $paths.KeyReader, $paths.Key)) {
    if (-not (Test-Path -LiteralPath $path)) { throw ('Missing file: ' + $path) }
}
[void](Read-HubKey $paths)
[void](Get-Content -LiteralPath $paths.Catalog -Raw -Encoding UTF8 | ConvertFrom-Json)
Write-Host '[OK] DS 文件齐全，模型目录可读取，加密密钥可解密。' -ForegroundColor Green
Write-Host '此检查未向 API 发起请求。需要检查真实连接时请运行 Test-DeepSeek.cmd。'
