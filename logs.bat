@echo off
echo WhatsApp Ping Bot - View Logs
echo.

if not exist "bot.log" (
    echo No log file found.
    echo The bot may not have been started yet, or logs are displayed in the terminal.
    echo.
    pause
    exit /b
)

echo Displaying last 50 lines of bot.log...
echo Press Ctrl+C to exit
echo.
echo ========================================
echo.

REM Display last 50 lines
powershell -Command "Get-Content bot.log -Tail 50"

echo.
echo ========================================
echo.
echo To follow live logs, run: powershell Get-Content bot.log -Wait -Tail 20
echo.
pause
