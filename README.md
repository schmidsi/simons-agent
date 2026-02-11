# Simon's Agent

Personal Claude Code agent running in Docker on Hetzner via Coolify at `simons-agent.oskamai.com`.

## What is this?

An isolated container that runs `claude --dangerously-skip-permissions` as a background worker. SSH in, give it tasks, let it work while you're away. This repo is the supervisor — Claude clones other repos into `/workspace` to work on them.

## Quick start (local)

```bash
cp .env.example .env
# Fill in GH_SSH_KEY
docker compose up -d
docker exec -it simons-agent bash
claude login              # first time only
claude --dangerously-skip-permissions
```

## Deploy (Coolify)

1. Add this repo as a docker-compose resource in Coolify
2. Set environment variable: `GH_SSH_KEY`
3. Assign domain: `simons-agent.oskamai.com`
4. Deploy
5. SSH into Hetzner, `docker exec -it simons-agent bash`
6. `claude login` (first time — persists in volume)

## Fast track for future sessions

- **Plan**: `tasks/000-mvp-plan.md`
- **Container**: `docker exec -it simons-agent bash`
- **Workspace**: `/workspace` (persistent volume)
- **Claude config**: `/home/node/.claude` (persistent volume)
- **Dev servers**: Start on port 80, accessible at `simons-agent.oskamai.com`

## Architecture

See `tasks/000-mvp-plan.md` for full details.

Docker-compose with a single `agent` service. Node 20 base, Claude Code + dev tools installed. OAuth login for Claude (persisted in volume). SSH key for dedicated GitHub account injected at startup via env var. Non-root `node` user for basic isolation.
