@echo off
setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"
set "DIST_DIR=%PROJECT_DIR%\dist"

echo [1/2] Preparing playtest packet...
call "%PROJECT_DIR%\tools\prepare_playtest_packet.cmd"
if errorlevel 1 goto :fail

set "LATEST_ZIP="
for /f "delims=" %%F in ('dir /b /a-d /od "%DIST_DIR%\raiden-prototype-showcase-rc-0.4-*.zip" 2^>nul') do set "LATEST_ZIP=%%F"
if not defined LATEST_ZIP goto :fail

set "PACKET_SUFFIX=%RANDOM%-%RANDOM%"
set "PACKET_DIR=%DIST_DIR%\public-demo-packet-rc-0.4-%PACKET_SUFFIX%"

echo [2/2] Preparing public demo packet...
mkdir "%PACKET_DIR%"
if errorlevel 1 goto :fail

copy /Y "%DIST_DIR%\%LATEST_ZIP%" "%PACKET_DIR%\%LATEST_ZIP%" >nul
copy /Y "%PROJECT_DIR%\README.md" "%PACKET_DIR%\README.md" >nul
copy /Y "%PROJECT_DIR%\docs\public-demo-release-note.md" "%PACKET_DIR%\public-demo-release-note.md" >nul
copy /Y "%PROJECT_DIR%\docs\public-demo-known-issues.md" "%PACKET_DIR%\public-demo-known-issues.md" >nul
copy /Y "%PROJECT_DIR%\docs\public-demo-package-checklist.md" "%PACKET_DIR%\public-demo-package-checklist.md" >nul
copy /Y "%PROJECT_DIR%\docs\asset-license-checklist.md" "%PACKET_DIR%\asset-license-checklist.md" >nul
copy /Y "%PROJECT_DIR%\docs\capture-checklist.md" "%PACKET_DIR%\capture-checklist.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-quick-start.md" "%PACKET_DIR%\playtest-quick-start.md" >nul
copy /Y "%PROJECT_DIR%\docs\playtest-feedback-form.md" "%PACKET_DIR%\playtest-feedback-form.md" >nul
copy /Y "%PROJECT_DIR%\docs\external-playtest-plan.md" "%PACKET_DIR%\external-playtest-plan.md" >nul

echo Public demo packet created:
echo %PACKET_DIR%
goto :eof

:fail
echo Failed to prepare public demo packet.
exit /b 1
