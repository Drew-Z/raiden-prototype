@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"
set "APPDATA=%PROJECT_DIR%\.godot-user"
set "LOCALAPPDATA=%PROJECT_DIR%\.godot-user"

if not exist "%APPDATA%" mkdir "%APPDATA%"

echo Using local user data: %APPDATA%
"D:\Development\Godot\Godot_v4.6.1-stable_win64.exe" --path "%PROJECT_DIR%"

endlocal
