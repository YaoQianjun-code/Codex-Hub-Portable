@echo off
chcp 65001 >nul
title Codex Hub - DeepSeek Setup
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Configure-DeepSeek-Interactive.ps1"
exit /b %ERRORLEVEL%
