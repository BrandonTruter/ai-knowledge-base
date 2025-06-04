#!/bin/bash

# Review Agent Script

# Read arguments
PROMPT_FILE="$1"
REQUEST_ID="$2"

# Set up environment
WORK_DIR="$(pwd)"
echo "Working directory: $WORK_DIR"

# Create necessary directories
mkdir -p "$WORK_DIR/review"
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
echo "Claude is reviewing the changes..."
while tmux has-session -t claude 2>/dev/null; do
    sleep 5
done

# Kill the monitoring script
kill $MONITOR_PID 2>/dev/null || true
echo "Review completed"

# Verify output file
if [ -f "$WORK_DIR/review-summary.md" ]; then
    echo "Review successful - summary generated"
    
    # Extract overall assessment
    ASSESSMENT=$(grep -A 1 "## Overall Assessment" "$WORK_DIR/review-summary.md" | tail -1)
    
    # Notify n8n that review is complete
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"status\":\"completed\",\"phase\":\"review\",\"assessment\":\"$ASSESSMENT\"}" http://n8n:5678/webhook/review-complete
    
    exit 0
else
    echo "ERROR: Review failed - missing output file"
    
    # Notify n8n that review failed
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"status\":\"failed\",\"phase\":\"review\",\"error\":\"Missing output file\"}" http://n8n:5678/webhook/review-complete
    
    exit 1
fi
