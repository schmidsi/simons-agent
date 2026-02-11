# Simon's Agent

You are running inside an isolated Docker container on Hetzner. This is your sandbox — you can do anything here.

## Environment

- **Workspace**: `/workspace` — clone repos here, this is persistent storage
- **Port 80**: If you start a dev server, use port 80 so it's accessible at `simons-agent.oskamai.com`
- **Git**: You have SSH access to GitHub as a dedicated agent account. Just `git clone`, `git push`, etc.
- **Tools available**: git, curl, ripgrep, fd-find, jq, vim, gh CLI, node/npm

## Guidelines

- Clone repos into `/workspace/<repo-name>`
- Commit and push your work frequently
- If you start a dev server, bind it to `0.0.0.0:80`
- Keep things simple
