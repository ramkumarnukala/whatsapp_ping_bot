#!/bin/bash
cd "$(dirname "$0")"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Stopping WhatsApp Ping Bot..."
echo ""

STOPPED=false

# Stop PM2 process
if command_exists pm2 && pm2 list | grep -q "ping-bot"; then
    pm2 stop ping-bot
    pm2 delete ping-bot
    echo "✓ Stopped PM2 process"
    STOPPED=true
fi

# Stop PID-based process
if [ -f "bot.pid" ]; then
    PID=$(cat bot.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill -9 $PID 2>/dev/null || true
        echo "✓ Killed bot process (PID: $PID)"
        STOPPED=true
    fi
    rm -f bot.pid
fi

# Kill any remaining node processes
if pkill -9 -f "node.*index.js" 2>/dev/null; then
    echo "✓ Killed remaining node processes"
    STOPPED=true
fi

# Kill ALL Chromium/Chrome instances (comprehensive)
echo "Killing all Chromium/Chrome instances..."
pkill -9 chrome 2>/dev/null || true
pkill -9 chromium 2>/dev/null || true
pkill -9 chromium-browser 2>/dev/null || true
pkill -9 -f "chrome" 2>/dev/null || true
pkill -9 -f "chromium" 2>/dev/null || true
pkill -9 -f "puppeteer" 2>/dev/null || true
pkill -9 -f "HeadlessChrome" 2>/dev/null || true
pkill -9 -f "chrome-sandbox" 2>/dev/null || true
killall -9 chrome 2>/dev/null || true
killall -9 chromium 2>/dev/null || true
killall -9 chromium-browser 2>/dev/null || true
echo "✓ Killed all Chrome/Chromium processes"
STOPPED=true

pkill -9 -f "puppeteer" 2>/dev/null || true

if [ "$STOPPED" = true ]; then
    echo ""
    echo "✓ Bot stopped successfully"
else
    echo "ℹ Bot is not running"
fi
