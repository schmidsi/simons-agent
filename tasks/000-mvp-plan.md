# 000: MVP Plan — Simon's Personal Agent

## Goal

Run Claude Code (`claude --dangerously-skip-permissions`) in an isolated Docker container on Hetzner via Coolify. Accessible for background work when Simon is away from his computer. Port 80 exposed for any dev servers Claude spins up.

## Architecture

**Docker-compose project** deployed via Coolify (Coolify natively supports docker-compose).

### Container: `agent`

- **Base**: `node:20` (same as hackathon-judging reference)
- **Installed tools**: git, curl, ripgrep, fd-find, jq, vim, gh CLI, Claude Code (npm global)
- **Git identity**: `Simon Agent <simon+agent@schmid.io>`
- **Port 80** exposed — Coolify's reverse proxy routes a subdomain here (e.g. `agent.yourdomain.xyz`), handles SSL
- **Volumes**:
  - `workspace` — persistent volume for `/workspace` (survives container rebuilds, not catastrophic if lost)
  - `claude-config` — persistent volume for `/home/node/.claude` (auth state, settings)
- **Env vars**:
  - `ANTHROPIC_API_KEY` — Claude API access
  - `GH_SSH_KEY` — private SSH key for dedicated GitHub agent account, written to `~/.ssh/id_ed25519` at startup

### How it works (MVP)

1. Deploy via Coolify (push to repo, Coolify builds & runs)
2. SSH into Hetzner, `docker exec -it simons-agent bash`
3. Run `claude --dangerously-skip-permissions` interactively
4. Claude works in `/workspace`, can start dev servers on port 80
5. Coolify routes subdomain → container port 80 with SSL

### Entrypoint

1. Write `$GH_SSH_KEY` env var → `~/.ssh/id_ed25519` (chmod 600)
2. Configure SSH for GitHub (`StrictHostKeyChecking no`)
3. Keep container alive (`tail -f /dev/null` or `sleep infinity`)

No auto-start of Claude — MVP is interactive-first.

### Security model

- Runs as non-root `node` user
- `--dangerously-skip-permissions` is fine because the container IS the sandbox
- Dedicated GitHub account with access only to repos the agent should touch
- SSH key injected at runtime via env var (not baked into image)
- Persistent volumes are convenient but not critical — losing them is annoying, not a disaster

## Decisions Made

1. **GitHub access**: Dedicated GitHub account, SSH key passed as `GH_SSH_KEY` env var, written to disk at container startup. Simple and works well with Coolify's env var management.

2. **Port strategy**: Coolify handles domain routing + SSL. Container exposes port 80. Claude should start dev servers on port 80 directly (or we add a simple proxy later if needed).

3. **Persistent storage**: Docker named volumes for workspace and Claude config. Survive rebuilds. Not mission-critical data.

4. **Security**: Non-root `node` user + container isolation. Good enough for MVP.

## Files to Create

- `Dockerfile` — container image
- `docker-compose.yml` — service definition for Coolify
- `entrypoint.sh` — SSH key setup + keep-alive
- `.env.example` — documents required env vars
- `.gitignore` — excludes `.env`
- `CLAUDE.md` — instructions for Claude when working inside the container
- `README.md` — quick overview + fast-track for future sessions

## Future (not MVP)

- **Telegram bot**: Second container in compose, communicates with agent container
- Auto-task execution (agent picks up task files and works on them)
- Web UI for monitoring
- Multi-agent orchestration
