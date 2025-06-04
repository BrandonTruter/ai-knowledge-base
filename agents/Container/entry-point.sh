#!/bin/bash
# Entry point script for MAF agent container

# Set up environment
export PATH="/opt/claude-code/bin:$PATH"
export NODE_ENV=production

# Read environment variables
AGENT_TYPE="${AGENT_TYPE:-default}"
REQUEST_ID="${REQUEST_ID:-unknown}"
LOG_FILE="/logs/${REQUEST_ID}-${AGENT_TYPE}.log"

# Function for logging
log() {
  local message="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

log "Starting container with agent type: ${AGENT_TYPE}"
log "Request ID: ${REQUEST_ID}"

# Initialize Tailscale if required
if [ "${USE_TAILSCALE}" = "true" ]; then
  log "Initializing Tailscale..."
  sudo tailscale up --accept-routes --accept-dns --shields-up
  TAILSCALE_IP=$(tailscale ip -4)
  log "Tailscale initialized with IP: ${TAILSCALE_IP}"
fi

# Set up Claude Code
log "Setting up Claude Code..."
claude config add allowedTools BashTool
claude config add allowedTools FileEditTool
claude config add allowedTools FileWriteTool
log "Claude Code configured"

# Determine which script to run
SCRIPT_PATH=""
case "${AGENT_TYPE}" in
  "analysis")
    SCRIPT_PATH="/scripts/analysis_agent.sh"
    ;;
  "implementation")
    SCRIPT_PATH="/scripts/implementation_agent.sh"
    ;;
  "review")
    SCRIPT_PATH="/scripts/review_agent.sh"
    ;;
  "dependency")
    SCRIPT_PATH="/scripts/dependency_agent.sh"
    ;;
  *)
    SCRIPT_PATH="/scripts/default_agent.sh"
    ;;
esac

# Check if script exists
if [ ! -f "${SCRIPT_PATH}" ]; then
  log "ERROR: Script not found: ${SCRIPT_PATH}"
  exit 1
fi

# Execute the script
log "Executing script: ${SCRIPT_PATH}"
bash "${SCRIPT_PATH}" "${REQUEST_ID}" "${AGENT_TYPE}"
RESULT=$?

if [ ${RESULT} -eq 0 ]; then
  log "Script executed successfully"
else
  log "Script execution failed with exit code: ${RESULT}"
fi

log "Container execution complete"
exit ${RESULT}
