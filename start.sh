#!/bin/bash
set -e
cd "$(dirname "$0")"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting WhatsApp Ping Bot..."
echo ""

# Check dependencies
if [ ! -d "node_modules" ]; then
    echo "Running setup..."
    ./setup.sh
    exit 0
fi

# Check for force relogin flag
FORCE_RELOGIN=false
if [ "$1" == "--relogin" ] || [ "$1" == "-r" ]; then
    FORCE_RELOGIN=true
    echo "Force relogin requested."
    echo ""
    
    # Stop bot if running
    echo "Stopping bot and all related processes..."
    
    # Stop PM2 process
    if command_exists pm2 && pm2 list | grep -q "ping-bot"; then
        pm2 stop ping-bot 2>/dev/null || true
        pm2 delete ping-bot 2>/dev/null || true
        echo "✓ Stopped PM2 process"
    fi
    
    # Stop PID-based process
    if [ -f "bot.pid" ]; then
        PID=$(cat bot.pid)
        if ps -p $PID > /dev/null 2>&1; then
            kill -9 $PID 2>/dev/null || true
            echo "✓ Killed bot process (PID: $PID)"
        fi
        rm -f bot.pid
    fi
    
    # Kill ALL node processes running index.js
    pkill -9 -f "node.*index.js" 2>/dev/null && echo "✓ Killed all node processes" || true
    
    # Detect OS
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        # Windows - use taskkill
        echo "Killing all Chromium/Chrome instances (Windows)..."
        taskkill //F //IM chrome.exe //T 2>/dev/null || true
        taskkill //F //IM node.exe //T 2>/dev/null || true
        echo "✓ Killed all Chrome/Node processes"
    else
        # Linux - use pkill
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
    fi
    
    # Wait for processes to fully terminate and release file locks
    echo "Waiting for processes to terminate and release file locks..."
    sleep 10
    
    # Kill any zombie processes (second pass)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        taskkill //F //IM chrome.exe //T 2>/dev/null || true
        taskkill //F //IM node.exe //T 2>/dev/null || true
    else
        pkill -9 chrome 2>/dev/null || true
        pkill -9 chromium 2>/dev/null || true
    fi
    sleep 3
    
    # Force clear session folders (with retries if locked)
    echo "Clearing old session..."
    for i in {1..5}; do
        if rm -rf .wwebjs_auth .wwebjs_cache 2>/dev/null; then
            # Verify actually deleted
            if [ ! -d ".wwebjs_auth" ] && [ ! -d ".wwebjs_cache" ]; then
                echo "✓ Session cleared successfully"
                break
            fi
        fi
        
        echo "Retry $i/5: Files still locked. Killing remaining processes..."
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            taskkill //F //IM chrome.exe //T 2>/dev/null || true
            taskkill //F //IM node.exe //T 2>/dev/null || true
        else
            pkill -9 chrome 2>/dev/null || true
            pkill -9 chromium 2>/dev/null || true
            pkill -9 -f "node.*index.js" 2>/dev/null || true
        fi
        sleep 4
    done
    
    # Final check - if still exists, force remove
    if [ -d ".wwebjs_auth" ] || [ -d ".wwebjs_cache" ]; then
        echo "Files still locked. Applying force removal..."
        
        # Change permissions
        chmod -R 777 .wwebjs_auth .wwebjs_cache 2>/dev/null || true
        
        # Windows: Use attrib and del
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            attrib -R -S -H .wwebjs_auth\\*.* //S //D 2>/dev/null || true
            attrib -R -S -H .wwebjs_cache\\*.* //S //D 2>/dev/null || true
            cmd //c "rmdir /S /Q .wwebjs_auth 2>nul" || true
            cmd //c "rmdir /S /Q .wwebjs_cache 2>nul" || true
        fi
        
        # Linux: standard rm
        rm -rf .wwebjs_auth .wwebjs_cache 2>/dev/null || true
        sleep 2
        
        # Final verification
        if [ -d ".wwebjs_auth" ] || [ -d ".wwebjs_cache" ]; then
            echo "⚠ Warning: Some session files may still be locked"
            echo "This is normal on Windows. The bot will try to use existing session."
        else
            echo "✓ Session cleared with force removal"
        fi
    fi
    echo ""
fi

# Check if already authenticated (skip if force relogin)
if [ -d ".wwebjs_auth" ] && [ "$FORCE_RELOGIN" = false ]; then
    # Already logged in, start in background
    echo "Already authenticated. Starting in background..."
    echo "To force relogin, use: ./start.sh --relogin"
    echo ""
    
    if command_exists pm2; then
        # Check if already running
        if pm2 list | grep -q "ping-bot"; then
            echo "Bot is already running. Restarting..."
            pm2 restart ping-bot
        else
            pm2 start index.js --name ping-bot
            pm2 save
        fi
        echo ""
        echo "✓ Started with PM2"
        echo "  pm2 logs ping-bot"
        echo "  pm2 stop ping-bot"
    else
        # Check if already running
        if [ -f "bot.pid" ] && ps -p $(cat bot.pid) > /dev/null 2>&1; then
            echo "Bot is already running (PID: $(cat bot.pid))"
            echo "Stop it first: ./stop.sh"
            exit 1
        fi
        
        nohup npm start > bot.log 2>&1 &
        echo $! > bot.pid
        echo ""
        echo "✓ Started in background (PID: $(cat bot.pid))"
        echo "  tail -f bot.log"
        echo "  ./stop.sh"
    fi
else
    # First time or session expired - need to login
    echo "Authentication needed - Scan QR code"
    echo "After successful login, press Ctrl+C to switch to background"
    echo ""
    
    # Trap Ctrl+C
    trap 'switch_to_background' INT
    
    switch_to_background() {
        echo ""
        echo ""
        echo "✓ Login successful! Switching to background..."
        sleep 2
        
        if command_exists pm2; then
            pm2 start index.js --name ping-bot
            pm2 save
            echo ""
            echo "✓ Running in background with PM2"
            echo "  pm2 logs ping-bot"
            echo "  pm2 stop ping-bot"
        else
            nohup npm start > bot.log 2>&1 &
            echo $! > bot.pid
            echo ""
            echo "✓ Running in background (PID: $(cat bot.pid))"
            echo "  tail -f bot.log"
            echo "  ./stop.sh"
        fi
        exit 0
    }
    
    # Start in foreground for login
    npm start
fi