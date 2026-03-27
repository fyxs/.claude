@echo off
cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "sync-backup.ps1" -BackupRoot "D:\10Backups\Claude-Config"
pause
