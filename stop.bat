@echo off
echo Stopping WhatsApp Ping Bot...
echo.

set "STOPPED=false"

REM Kill all node processes
taskkill /F /IM node.exe /T >nul 2>&1
if not errorlevel 1 (
    echo Killed all Node processes
    set "STOPPED=true"
)

REM Kill all Chrome processes
taskkill /F /IM chrome.exe /T >nul 2>&1
if not errorlevel 1 (
    echo Killed all Chrome processes
    set "STOPPED=true"
)

REM Delete PID file if exists
if exist "bot.pid" del /F /Q bot.pid >nul 2>&1

if "%STOPPED%"=="true" (
    echo.
    echo Bot stopped successfully
) else (
    echo Bot is not running
)

echo.
pause
