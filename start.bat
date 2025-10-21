@echo off
setlocal enabledelayedexpansion

echo Starting WhatsApp Ping Bot...
echo.

REM Check if node_modules exists
if not exist "node_modules\" (
    echo Dependencies not installed. Running setup...
    call setup.bat
    exit /b
)

REM Check for relogin flag
set "RELOGIN=false"
if "%1"=="--relogin" set "RELOGIN=true"
if "%1"=="-r" set "RELOGIN=true"

if "%RELOGIN%"=="true" (
    echo Force relogin requested.
    echo.
    
    echo Stopping bot and all related processes...
    
    REM Kill all node and chrome processes
    taskkill /F /IM node.exe /T >nul 2>&1
    taskkill /F /IM chrome.exe /T >nul 2>&1
    echo Killed all Chrome/Node processes
    
    echo Waiting for processes to terminate and release file locks...
    timeout /t 10 /nobreak >nul
    
    REM Kill again (zombie processes)
    taskkill /F /IM node.exe /T >nul 2>&1
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
    
    echo Clearing old session...
    if exist ".wwebjs_auth" (
        attrib -R -S -H .wwebjs_auth\*.* /S /D >nul 2>&1
        rmdir /S /Q .wwebjs_auth >nul 2>&1
    )
    if exist ".wwebjs_cache" (
        attrib -R -S -H .wwebjs_cache\*.* /S /D >nul 2>&1
        rmdir /S /Q .wwebjs_cache >nul 2>&1
    )
    
    REM Retry deletion if still exists
    timeout /t 2 /nobreak >nul
    if exist ".wwebjs_auth" rmdir /S /Q .wwebjs_auth >nul 2>&1
    if exist ".wwebjs_cache" rmdir /S /Q .wwebjs_cache >nul 2>&1
    
    if exist ".wwebjs_auth" (
        echo Warning: Some session files may still be locked
        echo This is normal on Windows. Continuing...
    ) else (
        echo Session cleared successfully
    )
    echo.
)

REM Check if already authenticated
if exist ".wwebjs_auth" (
    if "%RELOGIN%"=="false" (
        echo Already authenticated. Starting in foreground...
        echo To force relogin, use: start.bat --relogin
        echo.
        echo Press Ctrl+C to stop the bot
        echo.
        call npm start
        exit /b
    )
)

REM First time or relogin - need to scan QR
echo Authentication needed - Scan QR code
echo After successful login, press Ctrl+C to stop
echo Then run start.bat again to run in background
echo.

call npm start
