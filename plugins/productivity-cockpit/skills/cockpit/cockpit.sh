#!/bin/bash
# Cockpit v2.0 Launcher for WSL/Linux
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "🚀 Starting Cockpit Bridge..."
python3 "$DIR/bridge.py" &
BRIDGE_PID=$!

# Wait for server to be ready
sleep 2

echo "🌐 Opening Dashboard..."
# Try to open browser (works in most WSL setups with BROWSER env or tools installed)
if command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:8001"
elif command -v explorer.exe > /dev/null; then
    explorer.exe "http://localhost:8001"
else
    echo "Done! Access your Cockpit at: http://localhost:8001"
fi

# Keep script running to monitor bridge? (Optional)
# To stop everything, just Ctrl+C
wait $BRIDGE_PID
