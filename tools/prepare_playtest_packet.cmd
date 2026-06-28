@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"
set "DIST_DIR=%PROJECT_DIR%\dist"

echo [1/2] Building latest demo package...
call "%PROJECT_DIR%\tools\run_demo_readiness_check.cmd"
if errorlevel 1 goto :fail

set "LATEST_ZIP="
for /f "delims=" %%F in ('dir /b /a-d /od "%DIST_DIR%\raiden-prototype-showcase-rc-0.4-*.zip" 2^>nul') do set "LATEST_ZIP=%%F"
if not defined LATEST_ZIP goto :fail

set "PACKET_SUFFIX=%RANDOM%-%RANDOM%"
set "PACKET_DIR=%DIST_DIR%\playtest-packet-rc-0.4-%PACKET_SUFFIX%"

echo [2/2] Preparing playtest packet...
mkdir "%PACKET_DIR%"
if errorlevel 1 goto :fail

copy /Y "%DIST_DIR%\%LATEST_ZIP%" "%PACKET_DIR%\%LATEST_ZIP%" >nul
copy /Y "%PROJECT_DIR%\README.md" "%PACKET_DIR%\README.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-quick-start.md" "%PACKET_DIR%\playtest-quick-start.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-feedback-form.md" "%PACKET_DIR%\playtest-feedback-form.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-session-notes.md" "%PACKET_DIR%\playtest-session-notes.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-decision-matrix.md" "%PACKET_DIR%\playtest-decision-matrix.md" >nul
copy /Y "%PROJECT_DIR%\docs\external-playtest-plan.md" "%PACKET_DIR%\external-playtest-plan.md" >nul

echo Playtest packet created:
echo %PACKET_DIR%
goto :eof

:fail
echo Failed to prepare playtest packet.
exit /b 1
