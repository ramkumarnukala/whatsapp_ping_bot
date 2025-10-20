#!/bin/bash
cd "$(dirname "$0")"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check PM2
if command_exists pm2 && pm2 list | grep -q "ping-bot"; then
    echo "✓ Running (PM2)"
    pm2 list ping-bot
    exit 0
fi

# Check PID file
if [ -f "bot.pid" ]; then
    PID=$(cat bot.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo "✓ Running (PID: $PID)"
        ps -p $PID -o pid,cmd,%cpu,%mem
        exit 0
    else
        rm bot.pid
    fi
fi

# Find process
PIDS=$(pgrep -f "node.*index.js")
if [ ! -z "$PIDS" ]; then
    echo "✓ Running (PID: $PIDS)"
    ps -p $PIDS -o pid,cmd,%cpu,%mem
    exit 0
fi

echo "✗ Not running"
echo "Start with: ./start.sh"
