# 000: MVP Plan — Simon's Personal Agent

## Goal

Run Claude Code (`claude --dangerously-skip-permissions`) in an isolated Docker container on Hetzner via Coolify. Accessible for background work when Simon is away from his computer. Port 80 exposed for any dev servers Claude spins up.

## Architecture

**Docker-compose project** deployed via Coolify (Coolify natively supports docker-compose).

### Container: `agent`

- **Base**: `node:20` (same as hackathon-judging reference)
- **Installed tools**: git, curl, ripgrep, fd-find, jq, vim, gh CLI, Claude Code (npm global)
- **Git identity**: `Simon Agent <simon+agent@schmid.io>`
- **Port 80** exposed — Coolify routes `simons-agent.oskamai.com` here, handles SSL
- **Volumes**:
  - `workspace` — persistent volume for `/workspace` (survives container rebuilds, not catastrophic if lost)
  - `claude-config` — persistent volume for `/home/node/.claude` (auth state, settings)
- **Auth**:
  - Claude: OAuth login (`claude login`), session persisted in `~/.claude` volume. Interactive first use, then persists.
  - GitHub: `GH_SSH_KEY` env var — private SSH key for dedicated GitHub agent account, written to `~/.ssh/id_ed25519` at startup
- **Role**: This repo is the supervisor/manager. Claude clones other repos into `/workspace` to work on them.

### How it works (MVP)

1. Deploy via Coolify (push to repo, Coolify builds & runs)
2. SSH into Hetzner, `docker exec -it simons-agent bash`
3. Run `claude login` (first time only — persists in volume)
4. Run `claude --dangerously-skip-permissions` interactively
5. Clone repos into `/workspace`, work on them
6. Dev servers on port 80 → accessible at `simons-agent.oskamai.com`

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

1. **Domain**: `simons-agent.oskamai.com` — wildcard DNS on `oskamai.com`, Coolify handles SSL.

2. **Claude auth**: OAuth login (interactive, first time). Session persists in `~/.claude` Docker volume. No API key needed.

3. **GitHub access**: Dedicated GitHub account, SSH key passed as `GH_SSH_KEY` env var, written to disk at container startup.

4. **Port strategy**: Coolify handles domain routing + SSL. Container exposes port 80 directly.

5. **Persistent storage**: Docker named volumes for workspace and Claude config. Survive rebuilds. Not mission-critical data.

6. **Security**: Non-root `node` user + container isolation. Good enough for MVP.

7. **Role**: This repo = supervisor. Claude clones other repos into `/workspace` to work on them.

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
