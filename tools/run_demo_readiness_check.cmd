@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"

echo [1/2] Running showcase verification...
call "%PROJECT_DIR%\tools\run_showcase_verification.cmd"
if errorlevel 1 goto :fail

echo [2/2] Preparing demo package...
call "%PROJECT_DIR%\tools\prepare_showcase_package.cmd"
if errorlevel 1 goto :fail

echo Demo readiness check completed.
echo Package output directory:
echo %PROJECT_DIR%\dist
goto :eof

:fail
echo Demo readiness check failed.
exit /b 1
