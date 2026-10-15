param([string]$ProfileRoot = $env:USERPROFILE)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Hub.Common.ps1')
[void](Test-HubDeepSeek (Get-HubPaths $ProfileRoot))
