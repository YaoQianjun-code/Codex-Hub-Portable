param([string]$KeyPath = (Join-Path $PSScriptRoot 'deepseek-key.dpapi'))
$ErrorActionPreference = 'Stop'
# Authentication helper: stdout must contain ONLY the token. Do not run manually.
$ptr = [IntPtr]::Zero
$secure = $null
try {
    Import-Module (Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1') -ErrorAction Stop
    $secure = [IO.File]::ReadAllText($KeyPath, [Text.Encoding]::UTF8) | ConvertTo-SecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    if ([string]::IsNullOrWhiteSpace($plain) -or $plain -match '\s') { throw 'Invalid key.' }
    [Console]::Out.WriteLine($plain)
    $plain = $null
}
catch {
    [Console]::Error.WriteLine('DeepSeek key unavailable. Run Configure-DeepSeek.cmd with the Windows account that owns this configuration.')
    exit 1
}
finally {
    if ($ptr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
    if ($secure) { $secure.Dispose() }
}
