@echo off
echo WhatsApp Ping Bot - Relogin
echo.

echo Stopping bot if running...
call stop.bat

echo.
echo Starting fresh login...
echo.

call start.bat --relogin
