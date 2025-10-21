@echo off
echo Installing WhatsApp Ping Bot dependencies...
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo Error: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js found: 
node --version
echo.

REM Install npm packages
echo Installing npm packages...
call npm install

if errorlevel 1 (
    echo.
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo ========================================
echo Setup complete!
echo ========================================
echo.
echo Next step: Run start.bat to begin
echo.
pause
