# 001: Automate Coolify Deployment

## Status: TODO

## Goal

Script the Coolify resource creation so deploying (or redeploying) is a single command instead of clicking through the UI.

## Approach

Coolify has a REST API. Relevant endpoint:

- `POST /api/v1/services` (preferred, newer)
- `POST /api/operations/create-dockercompose-application` (deprecated but works)

Takes `docker_compose_raw` directly, plus `project_uuid`, `server_uuid`, `environment_name`.

## Prerequisites

- Coolify API token (generate in Coolify → Keys & Tokens)
- `project_uuid` and `server_uuid` from Coolify (can be fetched via API too)

## Notes

- Could be a simple shell script or a task in this repo
- Could also set env vars (`GH_SSH_KEY`) and domain (`simons-agent.oskamai.com`) via API
