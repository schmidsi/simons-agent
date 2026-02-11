# Simon's Agent

Personal Claude Code agent running in Docker on Hetzner via Coolify.

## What is this?

An isolated container that runs `claude --dangerously-skip-permissions` as a background worker. SSH in, give it tasks, let it work while you're away. Coolify handles deployment, domain routing, and SSL.

## Quick start (local)

```bash
cp .env.example .env
# Fill in ANTHROPIC_API_KEY and GH_SSH_KEY
docker compose up -d
docker exec -it simons-agent bash
claude --dangerously-skip-permissions
```

## Deploy (Coolify)

1. Add this repo as a docker-compose resource in Coolify
2. Set environment variables: `ANTHROPIC_API_KEY`, `GH_SSH_KEY`
3. Assign a subdomain (e.g. `agent.yourdomain.xyz`)
4. Deploy

## Fast track for future sessions

- **Plan**: `tasks/000-mvp-plan.md`
- **Container**: `docker exec -it simons-agent bash`
- **Workspace**: `/workspace` (persistent volume)
- **Claude config**: `/home/node/.claude` (persistent volume)
- **Dev servers**: Start on port 80, accessible via Coolify subdomain

## Architecture

See `tasks/000-mvp-plan.md` for full details.

Docker-compose with a single `agent` service. Node 20 base, Claude Code + dev tools installed. SSH key for dedicated GitHub account injected at startup via env var. Non-root `node` user for basic isolation.
