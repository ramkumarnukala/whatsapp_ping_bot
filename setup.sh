#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "WhatsApp Ping Bot - Setup"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "Node.js not found!"
    echo ""
    echo "Install with:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    exit 1
fi

echo "Node.js: $(node -v)"
echo ""

# Install dependencies
echo "Installing dependencies..."
npm install

echo ""
echo "Setup complete! Run: ./start.sh"
./start.sh
