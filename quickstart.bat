@echo off
echo.
echo ========================================
echo   WhatsApp Ping Bot - Quick Start
echo ========================================
echo.

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [X] Node.js is NOT installed
    echo.
    echo Please install Node.js first:
    echo https://nodejs.org/
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Node.js is installed
)

REM Check npm packages
if not exist "node_modules\" (
    echo [ ] Dependencies not installed
    echo.
    echo Installing dependencies...
    call npm install
    if errorlevel 1 (
        echo.
        echo [X] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
) else (
    echo [OK] Dependencies already installed
)

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Starting the bot...
echo.
echo IMPORTANT:
echo 1. A QR code will appear - scan it with WhatsApp
echo 2. After scanning, press Ctrl+C
echo 3. Run start.bat again to start in background
echo.
pause

call npm start
