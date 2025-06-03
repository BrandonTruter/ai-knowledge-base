#!/bin/bash

# Implementation Agent Script

# Read arguments
PROMPT_FILE="$1"
REQUEST_ID="$2"
REPOSITORY="$3"

# Set up environment
WORK_DIR="$(pwd)"
REPO_DIR="/repositories/$REPOSITORY"
echo "Working directory: $WORK_DIR"
echo "Repository directory: $REPO_DIR"

# Ensure repository directory exists
if [ ! -d "$REPO_DIR" ]; then
  echo "ERROR: Repository directory does not exist: $REPO_DIR"
  exit 1
fi

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

# Switch to repository directory
cd "$REPO_DIR"

# Update status file
echo "Status: In Progress" > "repo-${REPOSITORY}-status.md"

# Start Claude in a tmux session
tmux new-session -d -s claude
tmux send-keys -t claude "cd $REPO_DIR && claude \"$PROMPT\"" C-m

# Monitor the execution and wait for completion
echo "Claude is implementing changes..."
while tmux has-session -t claude 2>/dev/null; do
    sleep 10
done

# Kill the monitoring script
kill $MONITOR_PID 2>/dev/null || true
echo "Implementation completed"

# Check if changes were made
if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
    echo "Changes detected, committing..."
    
    # Commit changes
    git add .
    git commit -m "Fix: Implemented solution for $REQUEST_ID"
    
    # Push changes
    git push origin HEAD
    
    # Create PR using GitHub CLI if available
    if command -v gh &> /dev/null; then
        echo "Creating pull request..."
        PR_URL=$(gh pr create --title "Fix: $REQUEST_ID" --body "Automated fix for $REQUEST_ID. See repo-${REPOSITORY}-status.md for details.")
        echo "Pull request created: $PR_URL"
        
        # Update status file with PR URL
        echo "Status: Completed" > "repo-${REPOSITORY}-status.md"
        echo "PR: $PR_URL" >> "repo-${REPOSITORY}-status.md"
    else
        echo "GitHub CLI not available, skipping PR creation"
        echo "Status: Completed" > "repo-${REPOSITORY}-status.md"
        echo "Branch: $(git rev-parse --abbrev-ref HEAD)" >> "repo-${REPOSITORY}-status.md"
    fi
    
    # Notify n8n that implementation is complete
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"repository\":\"$REPOSITORY\",\"status\":\"completed\",\"phase\":\"implementation\"}" http://n8n:5678/webhook/implementation-complete
    
    exit 0
else
    echo "No changes detected"
    echo "Status: Failed - No changes made" > "repo-${REPOSITORY}-status.md"
    
    # Notify n8n that implementation failed
    curl -X POST -H "Content-Type: application/json" -d "{\"requestId\":\"$REQUEST_ID\",\"repository\":\"$REPOSITORY\",\"status\":\"failed\",\"phase\":\"implementation\",\"error\":\"No changes made\"}" http://n8n:5678/webhook/implementation-complete
    
    exit 1
fi
