@echo off
echo WhatsApp Ping Bot - Status
echo.

REM Check if node process is running
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Status: RUNNING
    echo.
    echo Active Node.js processes:
    tasklist /FI "IMAGENAME eq node.exe"
) else (
    echo Status: NOT RUNNING
)

echo.

REM Check if session exists
if exist ".wwebjs_auth" (
    echo Session: AUTHENTICATED
) else (
    echo Session: NOT AUTHENTICATED
)

echo.
pause
