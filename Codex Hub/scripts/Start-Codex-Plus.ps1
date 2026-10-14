param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
$taskPreviousHome = $env:CODEX_HOME
try {
    $taskHome = Join-Path $env:USERPROFILE '.codex'
    if (-not (Test-Path -LiteralPath (Join-Path $taskHome 'config.toml'))) {
        throw "Existing configuration not found: $taskHome"
    }
    $env:CODEX_HOME = $taskHome
    $Host.UI.RawUI.WindowTitle = 'Codex Plus'
    Write-Host 'Codex Plus' -ForegroundColor Cyan
    Write-Host "CODEX_HOME = $env:CODEX_HOME"
    $taskCommand = Get-Command codex.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    $taskExe = if ($taskCommand) { $taskCommand.Source } else { $null }
    if (-not $taskExe) {
        $taskBin = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
        $taskCandidate = Get-ChildItem -LiteralPath $taskBin -Filter codex.exe -Recurse -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($taskCandidate) { $taskExe = $taskCandidate.FullName }
    }
    if (-not $taskExe) { throw 'Codex CLI was not found. Install or repair Codex, then retry.' }
    if ($CheckOnly) {
        Write-Host "Executable = $taskExe"
        & $taskExe --version
        if ($LASTEXITCODE -ne 0) { throw "Codex version check failed: $LASTEXITCODE" }
        return
    }
    & $taskExe
    if ($LASTEXITCODE -ne 0) { throw "Codex exited with code $LASTEXITCODE" }
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    if (-not $CheckOnly) { [void](Read-Host 'Press Enter to close') }
    throw
}
finally {
    if ($null -eq $taskPreviousHome) { Remove-Item Env:CODEX_HOME -ErrorAction SilentlyContinue }
    else { $env:CODEX_HOME = $taskPreviousHome }
}