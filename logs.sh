#!/bin/bash
cd "$(dirname "$0")"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check PM2
if command_exists pm2 && pm2 list | grep -q "ping-bot"; then
    pm2 logs ping-bot
    exit 0
fi

# Check log file
if [ -f "bot.log" ]; then
    tail -f bot.log
    exit 0
fi

echo "No logs found. Start bot with: ./start.sh -b"
