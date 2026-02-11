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

# Set up SSH access for the user
if [ -n "$SSH_AUTHORIZED_KEY" ]; then
    echo "$SSH_AUTHORIZED_KEY" > /home/node/.ssh/authorized_keys
    chmod 600 /home/node/.ssh/authorized_keys
    chown node:node /home/node/.ssh/authorized_keys
    echo "SSH authorized key configured."
else
    echo "Warning: SSH_AUTHORIZED_KEY not set. SSH login won't work."
fi

# Configure sshd to run on port 2222 as node user
cat > /etc/ssh/sshd_config.d/agent.conf <<SSHDEOF
Port 2222
PermitRootLogin no
PasswordAuthentication no
AllowUsers node
SSHDEOF

# Give node a login shell
usermod -s /bin/bash node

echo ""
echo "=== Simon's Agent ==="
echo "SSH: ssh -p 2222 node@<host>"
echo ""

# Start sshd in foreground
exec /usr/sbin/sshd -D
