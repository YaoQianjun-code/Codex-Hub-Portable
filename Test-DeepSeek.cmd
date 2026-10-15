@echo off
chcp 65001 >nul
title Codex Hub - DeepSeek Connection Test
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Test-DeepSeek.ps1"
set "TASK_RESULT=%ERRORLEVEL%"
pause
exit /b %TASK_RESULT%
