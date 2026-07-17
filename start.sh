#!/bin/bash

# GhostBustor Startup Script
# Usage: ./start.sh

echo "🎣 Starting GhostBustor..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required"
    exit 1
fi

# Start backend
echo "📡 Starting backend API..."
cd backend
pip install -q -r requirements.txt 2>/dev/null
python3 -c "import uvicorn; uvicorn.main(['main:app', '--reload', '--host', '0.0.0.0', '--port', '8000'])" &
BACKEND_PID=$!
cd ..

echo "✅ Backend: http://localhost:8000"
echo ""

# Start frontend
echo "🗺️  Starting frontend..."
cd frontend
python3 -m http.server 8080 &
FRONTEND_PID=$!
cd ..

echo "✅ Frontend: http://localhost:8080"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎣 GhostBustor is running!"
echo ""
echo "📊 Dashboard: http://localhost:8080"
echo "📡 API:       http://localhost:8000"
echo "📖 API Docs:  http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Wait for interrupt
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo ''; echo '🛑 GhostBustor stopped'; exit 0" INT
wait
