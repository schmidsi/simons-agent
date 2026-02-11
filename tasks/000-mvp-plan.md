# 000: MVP Plan — Simon's Personal Agent

## Goal

Run Claude Code (`claude --dangerously-skip-permissions`) in an isolated Docker container on Hetzner via Coolify. Accessible for background work when Simon is away from his computer. Port 80 exposed for any dev servers Claude spins up.

## Architecture

**Docker-compose project** deployed via Coolify (Coolify natively supports docker-compose).

### Container: `agent`

- **Base**: `node:20` (same as hackathon-judging reference)
- **Installed tools**: git, curl, ripgrep, fd-find, jq, vim, gh CLI, Claude Code (npm global)
- **Git identity**: `Simon Agent <simon+agent@schmid.io>`
- **Port 80** exposed — forwarded to whatever dev port Claude uses (via simple reverse proxy or socat)
- **Volumes**:
  - `workspace` — persistent volume for `/workspace` (survives container rebuilds)
  - `claude-config` — persistent volume for `/home/node/.claude` (auth state, settings)
- **Env**: `ANTHROPIC_API_KEY` passed in

### How it works (MVP)

1. Deploy via Coolify (push to repo, Coolify builds & runs)
2. SSH into Hetzner, `docker exec -it simons-agent bash`
3. Run `claude --dangerously-skip-permissions` interactively
4. Claude works in `/workspace`, can start dev servers on any port
5. Port 80 on the container maps to port 80 on the host → accessible via domain/IP

### Entrypoint

Simple: just keep the container alive (`tail -f /dev/null` or `bash` with tty). No auto-start of Claude — MVP is interactive-first.

## Open Questions

1. **SSH keys for GitHub**: Should we mount SSH keys (like hackathon-judging does) or use `gh auth` with a token? Token is simpler for Coolify deployment (just another env var).

2. **Port forwarding strategy**: Should port 80 inside the container just be left open and Claude uses it directly? Or do we want a lightweight reverse proxy (like caddy/nginx) that proxies to whatever port Claude's dev server runs on (3000, 5173, 8080, etc.)?

3. **Claude auth**: The `ANTHROPIC_API_KEY` env var should be enough. But do you also want Claude's OAuth/login state persisted? (The `~/.claude` volume handles this.)

4. **Coolify specifics**: Do you have a domain pointed at the Hetzner box already? Coolify typically handles SSL/domains — so we might not need port 80 at all if Coolify's reverse proxy handles routing.

5. **Security boundaries**: The reference project runs as `node` (non-root) and uses `--dangerously-skip-permissions`. Same approach here? Any repos/secrets that should be pre-loaded into the workspace volume?

6. **Telegram (future)**: Just noting for later — likely a small bot service (second container in the compose) that talks to the agent container. Not MVP.

## Files to Create

- `Dockerfile` — container image
- `docker-compose.yml` — service definition for Coolify
- `entrypoint.sh` — keeps container alive
- `.env.example` — documents required env vars
- `.gitignore` — excludes `.env`
- `CLAUDE.md` — instructions for Claude when working inside the container
- `README.md` — quick overview + fast-track for future sessions

## What's NOT in MVP

- No Telegram bot
- No auto-task execution
- No web UI
- No multi-agent orchestration
- No CI/CD pipeline (Coolify handles deploy on push)
