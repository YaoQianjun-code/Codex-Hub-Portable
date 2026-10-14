@echo off
chcp 65001 >nul
title Codex Hub Portable v4.2 Release Final

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Setup-CodexHub.ps1"

pause
