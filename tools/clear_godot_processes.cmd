@echo off
setlocal

echo Cleaning stale Godot processes...
taskkill /F /IM Godot_v4.6.1-stable_win64.exe >nul 2>nul
taskkill /F /IM Godot_v4.6.1-stable_win64_console.exe >nul 2>nul
echo Done.

endlocal
