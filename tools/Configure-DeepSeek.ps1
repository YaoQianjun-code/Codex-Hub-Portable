param(
    [string]$ProfileRoot = $env:USERPROFILE,
    [string]$BaseUrl,
    [string]$Model,
    [Security.SecureString]$ApiKey,
    [switch]$NonInteractive,
    [switch]$SkipConnectionTest
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Hub.Common.ps1')
$paths = Get-HubPaths $ProfileRoot
$previous = $null
if (Test-Path -LiteralPath $paths.Settings) {
    try { $previous = Read-HubSettings $paths } catch { Write-Warning '旧设置无法读取，将重新配置。' }
}
if (-not $BaseUrl) {
    $BaseUrl = if ($previous) { $previous.base_url } else { 'https://api.deepseek.com' }
    if (-not $NonInteractive) {
        $inputUrl = Read-Host "DS 接口基地址，回车使用 [$BaseUrl]"
        if ($inputUrl.Trim()) { $BaseUrl = $inputUrl.Trim() }
    }
}
$BaseUrl = Get-HubBaseUrl $BaseUrl
if (-not $Model) {
    $Model = if ($previous) { $previous.model } else { 'deepseek-flash' }
    if (-not $NonInteractive) {
        Write-Host '可选模型：deepseek-flash / deepseek-v4-pro；中转接口可填写其支持的模型名。'
        $inputModel = Read-Host "模型名称，回车使用 [$Model]"
        if ($inputModel.Trim()) { $Model = $inputModel.Trim() }
    }
}
if ($Model -notmatch '^[a-zA-Z0-9][a-zA-Z0-9._:/-]{0,199}$') { throw '模型名称格式不正确。' }
if (-not $ApiKey) {
    if ($NonInteractive) {
        if (-not (Test-Path -LiteralPath $paths.Key)) { throw 'NonInteractive requires ApiKey on first setup.' }
        [void](Read-HubKey $paths)
    }
    else {
        $prompt = '输入 DS API Key（输入不显示）'
        if (Test-Path -LiteralPath $paths.Key) { $prompt += '，回车保留已有密钥' }
        $ApiKey = Read-Host $prompt -AsSecureString
        if ($ApiKey.Length -eq 0) {
            $ApiKey.Dispose(); $ApiKey = $null
            if (-not (Test-Path -LiteralPath $paths.Key)) { throw '首次配置必须输入 DS API Key。' }
            [void](Read-HubKey $paths)
        }
    }
}
$encrypted = $null
if ($ApiKey) {
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiKey)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
        if ([string]::IsNullOrWhiteSpace($plain) -or $plain -match '\s' -or $plain.Length -gt 4096) {
            throw 'API Key 不能为空或包含空白字符。'
        }
        $encrypted = ConvertFrom-SecureString -SecureString $ApiKey
        $plain = $null
    }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}
if (Test-Path -LiteralPath $paths.Config) {
    Write-Host '将备份并更新 DS 的 config.toml；DS 的会话历史仍保存在原目录。' -ForegroundColor Yellow
    if (-not $NonInteractive -and
        (Get-Content -LiteralPath $paths.Config -Raw -Encoding UTF8) -notmatch '^# Codex Hub managed DeepSeek config') {
        if ((Read-Host '检测到非本工具生成的 DS 配置。备份后替换？输入 Y 继续') -notmatch '^[Yy]$') {
            throw '已取消，配置未更改。'
        }
    }
}
$psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$authArgs = @('-NoLogo', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', $paths.KeyReader)
$argsToml = '[' + (($authArgs | ForEach-Object { ConvertTo-HubTomlString $_ }) -join ', ') + ']'
$config = @"
# Codex Hub managed DeepSeek config v4.3
model = $(ConvertTo-HubTomlString $Model)
model_provider = "deepseek"
model_reasoning_effort = "high"
web_search = "disabled"
model_catalog_json = $(ConvertTo-HubTomlString $paths.Catalog)

[model_providers.deepseek]
name = "DeepSeek"
base_url = $(ConvertTo-HubTomlString $BaseUrl)
wire_api = "responses"
stream_idle_timeout_ms = 300000

[model_providers.deepseek.auth]
command = $(ConvertTo-HubTomlString $psExe)
args = $argsToml
timeout_ms = 15000
refresh_interval_ms = 300000
"@
$catalog = Get-HubModelCatalog $Model
$settings = @{ version = '4.3'; base_url = $BaseUrl; model = $Model; key_storage = 'Windows DPAPI CurrentUser' } | ConvertTo-Json
$reader = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Read-DeepSeekKey.ps1') -Raw -Encoding UTF8
$updates = [ordered]@{}
$updates[$paths.Catalog] = $catalog
$updates[$paths.KeyReader] = $reader
$updates[$paths.Settings] = $settings
if ($encrypted) { $updates[$paths.Key] = $encrypted }
# Write config last. Existing data is backed up before any replacement.
$updates[$paths.Config] = $config
$backup = Join-Path $paths.Internal ('backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8))
$originals = @{}
[void][IO.Directory]::CreateDirectory($backup)
foreach ($target in $updates.Keys) {
    if (Test-Path -LiteralPath $target) {
        $saved = Join-Path $backup ([IO.Path]::GetFileName($target))
        Copy-Item -LiteralPath $target -Destination $saved
        $originals[$target] = $saved
    }
    else { $originals[$target] = $null }
}
$written = @()
try {
    foreach ($target in $updates.Keys) {
        Write-HubText -Path $target -Text $updates[$target]
        $written += $target
    }
}
catch {
    foreach ($target in $written) {
        if ($originals[$target]) { Copy-Item -LiteralPath $originals[$target] -Destination $target -Force }
        else { Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue }
    }
    throw
}
Write-Host '[OK] DS 配置已保存；API Key 已用当前 Windows 账户加密。' -ForegroundColor Green
Write-Host ('配置目录：' + $paths.DeepSeek)
Write-Host ('旧文件备份：' + $backup)
if (-not $SkipConnectionTest) {
    try { [void](Test-HubDeepSeek $paths) }
    catch {
        Write-Warning ('配置已保存，但连接测试未通过：' + $_.Exception.Message)
        Write-Warning '请修正密钥/地址/模型或网络后运行 Test-DeepSeek.cmd；尚不能确认 DS 可以使用。'
        throw 'DS connection test failed.'
    }
}
