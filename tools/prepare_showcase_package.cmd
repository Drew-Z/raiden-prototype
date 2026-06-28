@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"
set "DIST_DIR=%PROJECT_DIR%\dist"
set "PACKAGE_SUFFIX=%RANDOM%-%RANDOM%"
set "PACKAGE_DIR=%DIST_DIR%\raiden-prototype-showcase-rc-0.4-%PACKAGE_SUFFIX%"
set "PACKAGE_ZIP=%DIST_DIR%\raiden-prototype-showcase-rc-0.4-%PACKAGE_SUFFIX%.zip"

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

mkdir "%PACKAGE_DIR%"

call :copy_dir assets || goto :fail
call :copy_dir docs || goto :fail
call :copy_dir scenes || goto :fail
call :copy_dir scripts || goto :fail
call :copy_dir tools || goto :fail

call :copy_file .gitignore || goto :fail
call :copy_file AGENTS.md || goto :fail
call :copy_file README.md || goto :fail
call :copy_file project.godot || goto :fail

attrib -R "%PACKAGE_DIR%\*" /S /D

powershell -NoProfile -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%PACKAGE_ZIP%' -CompressionLevel Optimal -Force"
if errorlevel 1 goto :fail

echo Showcase package created:
echo %PACKAGE_ZIP%
goto :eof

:copy_dir
if not exist "%PROJECT_DIR%\%~1" exit /b 0
robocopy "%PROJECT_DIR%\%~1" "%PACKAGE_DIR%\%~1" /E /XJ /COPY:DT /XF "*.log" "*.tmp" >nul
if errorlevel 8 exit /b 1
exit /b 0

:copy_file
if not exist "%PROJECT_DIR%\%~1" exit /b 0
copy /Y "%PROJECT_DIR%\%~1" "%PACKAGE_DIR%\%~1" >nul
if errorlevel 1 exit /b 1
exit /b 0

:fail
echo Failed to prepare showcase package.
exit /b 1
