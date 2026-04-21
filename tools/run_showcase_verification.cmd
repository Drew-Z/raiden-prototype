@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
for %%I in ("%PROJECT_DIR%") do set "PROJECT_DIR=%%~fI"
set "GODOT_EXE=D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe"
set "APPDATA=%PROJECT_DIR%\.godot-user"
set "LOCALAPPDATA=%PROJECT_DIR%\.godot-user"

if not exist "%APPDATA%" mkdir "%APPDATA%"

echo [1/3] Headless boot check...
"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --quit
if errorlevel 1 goto :fail

echo [2/3] Single-stage autoplay verification...
"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --fixed-fps 60 --quit-after 5200 --log-file "%PROJECT_DIR%\stage_single_verify.log" -- --autoplay --stage2
if errorlevel 1 goto :fail
findstr /C:"RUN_RESULT" "%PROJECT_DIR%\stage_single_verify.log" >nul
if errorlevel 1 goto :fail_semantic

echo [3/3] Chapter autoplay verification...
"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --fixed-fps 60 --quit-after 13600 --log-file "%PROJECT_DIR%\stage_chapter_verify.log" -- --autoplay --chapter
if errorlevel 1 goto :fail
findstr /C:"CHAPTER_RESULT" "%PROJECT_DIR%\stage_chapter_verify.log" >nul
if errorlevel 1 goto :fail_semantic

echo Showcase verification completed.
goto :eof

:fail
echo Showcase verification failed.
exit /b 1

:fail_semantic
echo Showcase verification finished without the expected result markers.
exit /b 1
