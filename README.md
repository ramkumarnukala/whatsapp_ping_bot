# WhatsApp Ping Bot

Monitor network devices in your private network via WhatsApp. Works on Ubuntu/Linux and Windows.

## 🚀 Quick Start

### Ubuntu/Linux:
```bash
# 1. Setup
chmod +x *.sh
./setup.sh

# 2. First time - Login with QR code
./start.sh
# Scan QR with WhatsApp → Press Ctrl+C → Bot runs in background

# 3. Next time - Auto-start in background
./start.sh
```

### Windows:
```cmd
REM 1. Setup
setup.bat

REM 2. First time - Login with QR code
start.bat
REM Scan QR with WhatsApp → Press Ctrl+C

REM 3. Next time - Start bot
start.bat
```

## 📱 Usage

Send these commands in WhatsApp (works in groups and private chats):

```
!ping 192.168.1.1       - Check if IP is online
!ping google.com        - Ping any hostname
!ping 192.168.1.1 10    - Ping with custom count (1-20)
!status                 - Check bot status
!help                   - Show help message
```

## 🔧 Management

### Ubuntu/Linux:
```bash
./start.sh          # Start bot (auto-background if logged in)
./start.sh --relogin # Force relogin with new QR code
./stop.sh           # Stop bot
./status.sh         # Check if running
./logs.sh           # View logs
```

### Windows:
```cmd
start.bat           # Start bot
start.bat --relogin # Force relogin with new QR code
stop.bat            # Stop bot
status.bat          # Check if running
logs.bat            # View logs
```

## 🔑 Relogin (Session Expired)

If WhatsApp session expires:

### Ubuntu/Linux:
```bash
./start.sh --relogin
# Scan new QR code → Press Ctrl+C → Done
```

### Windows:
```cmd
start.bat --relogin
REM Scan new QR code → Press Ctrl+C → Run start.bat again
```

## 📦 What You Get

- ✅ Ping devices in your private network
- ✅ Works in WhatsApp groups
- ✅ Runs 24/7 in background
- ✅ Auto-restart after login
- ✅ Free (no API costs)

## 💡 Requirements

- **Ubuntu/Linux** or **Windows 10/11**
- Node.js 14+
- WhatsApp account

