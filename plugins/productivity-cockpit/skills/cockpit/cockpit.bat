@echo off
:: Cockpit v2.0 Launcher for Windows
echo 🚀 Starting Cockpit Bridge...
start /B python "%~dp0bridge.py"

:: Wait for server to be ready
timeout /t 2 /nobreak >nul

echo 🌐 Opening Dashboard...
start http://localhost:8001

echo.
echo Cockpit is running in the background. 
echo To stop the bridge, close this terminal or use Task Manager to end Python processes.
pause
