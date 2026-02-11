#!/bin/bash
set -e

# Set up GitHub SSH key if provided
if [ -n "$GH_SSH_KEY" ]; then
    echo "$GH_SSH_KEY" > /home/node/.ssh/id_ed25519
    chmod 600 /home/node/.ssh/id_ed25519
    chown node:node /home/node/.ssh/id_ed25519

    cat > /home/node/.ssh/config <<SSHEOF
Host github.com
  HostName github.com
  User git
  IdentityFile /home/node/.ssh/id_ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking no
SSHEOF
    chown node:node /home/node/.ssh/config
    chmod 600 /home/node/.ssh/config

    echo "GitHub SSH key configured."
else
    echo "Warning: GH_SSH_KEY not set. Git push/pull over SSH won't work."
fi

echo ""
echo "=== Simon's Agent ==="
echo "Run: claude --dangerously-skip-permissions"
echo ""

# Drop to node user and keep container alive
exec gosu node sleep infinity
