FROM node:20

RUN apt-get update && apt-get install -y \
    git curl ripgrep fd-find jq tree vim unzip gosu \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# Git identity for agent
RUN git config --system user.email "simon+agent@schmid.io" \
    && git config --system user.name "Simon Agent"

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create workspace and home dirs
RUN mkdir -p /workspace /home/node/.claude /home/node/.ssh \
    && chown -R node:node /workspace /home/node/.claude /home/node/.ssh

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD pgrep -x "sleep" > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
