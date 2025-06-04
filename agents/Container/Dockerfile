FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1
ENV NODE_VERSION=18.x

# Install essential packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    jq \
    tmux \
    python3 \
    python3-pip \
    python3-venv \
    gnupg \
    ca-certificates \
    sudo \
    vim \
    unzip \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Claude Code and dependencies (placeholder - actual installation depends on availability)
# This is a simplified representation - actual installation may require more steps
RUN mkdir -p /opt/claude-code
COPY claude-code-installer.sh /opt/claude-code/
RUN chmod +x /opt/claude-code/claude-code-installer.sh \
    && /opt/claude-code/claude-code-installer.sh

# Create workspace directory structure
RUN mkdir -p /repositories \
    /scripts \
    /prompts \
    /logs \
    /state

# Add non-root user
RUN useradd -m -s /bin/bash -G sudo maf-user \
    && echo "maf-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up workspace permissions
RUN chown -R maf-user:maf-user /repositories \
    /scripts \
    /prompts \
    /logs \
    /state \
    /opt/claude-code

# Install required Node.js packages
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production

# Copy application code
COPY --chown=maf-user:maf-user . .

# Set up entry point
COPY --chown=maf-user:maf-user entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set up Tailscale (simplified installation)
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | apt-key add - \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list \
    && apt-get update \
    && apt-get install -y tailscale

# Switch to non-root user
USER maf-user
WORKDIR /app

# Expose required ports
EXPOSE 3000

# Set the entry point
ENTRYPOINT ["/entrypoint.sh"]
