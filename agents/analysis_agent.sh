#!/bin/bash
# Analysis Agent Script

# Read arguments
PROMPT_FILE="$1"
REQUEST_ID="$2"

# Set up environment
WORK_DIR="$(pwd)"
echo "Working directory: $WORK_DIR"

# Create necessary directories
mkdir -p "$WORK_DIR/analysis"
mkdir -p "$WORK_DIR/logs"

# Read the prompt
PROMPT=$(cat "$PROMPT_FILE")
echo "Read prompt from file"

# Configure Claude CLI
claude config add allowedTools BashTool
claude config add allowedTools FileEditTool
claude config add allowedTools FileWriteTool
echo "Configured Claude CLI"

# Kill any existing tmux sessions
echo "Killing any existing tmux sessions..."
tmux kill-server 2>/dev/null || true
sleep 1

# Create a monitor script for shift+tab detection
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "Starting monitor script - watching for (shift+tab) pattern"
while true; do
  if tmux capture-pane -p -t claude | grep -q "(shift+tab)"; then
    echo "Detected (shift+tab) - sending BTab key"
    tmux send-keys -t claude BTab
    sleep 2
  fi
  sleep 0.5
done
EOF

chmod +x monitor.sh

# Start the monitoring script in the background
./monitor.sh &
MONITOR_PID=$!
echo "Started monitoring script (PID: $MONITOR_PID)"

# Start Claude in a tmux session
tmux new-session -d -s claude
tmux send-keys -t claude "claude \"$PROMPT\"" C-m

# Monitor the execution and wait for completion
echo "Claude is analyzing the bug report..."
while tmux has-session -t claude 2>/dev/null; do
    sleep 5
done

# Kill the monitoring script
kill $MONITOR_PID 2>/dev/null || true
echo "Analysis completed"

# Verify output files
if [ -f "$WORK_DIR/analysis.md" ] && [ -f "$WORK_DIR/dependencies.md" ] && [ -f "$WORK_DIR/execution_plan.md" ]; then
    echo "Analysis successful - all required files generated"
    
    # Notify n8n that analysis is complete
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"status\":\"completed\",\"phase\":\"analysis\"}" http://n8n:5678/webhook/analysis-complete
    
    exit 0
else
    echo "ERROR: Analysis failed - missing output files"
    
    # Notify n8n that analysis failed
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"status\":\"failed\",\"phase\":\"analysis\",\"error\":\"Missing output files\"}" http://n8n:5678/webhook/analysis-complete
    
    exit 1
fi
