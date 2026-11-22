# agent-driven-py-project

A Python project developed by an OpenCode agent running inside a Docker Sandbox (SBX). The
agent works through a full learning loop: plan (planner) → implement (worker subagents in Git
worktrees) → verify (quality gate) → commit/PR.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) 0.13.8+ (manages CPython 3.15, dependencies, lockfile)
- `just` (task runner)
- Optional, for the sandbox workflow: `sbx` CLI (Docker Sandboxes, signed in) + Docker,
  `/dev/kvm` access, and a host SSH agent. See the companion
  [opencode-sbx-sandbox](https://github.com/atorizva/opencode-sbx-sandbox) repo.

## Getting started

```bash
uv sync          # install CPython 3.15 + dev dependencies
just check       # ruff check, ruff format --check, ty check, pytest
```

## Git hooks

`.githooks/prepare-commit-msg` appends the OpenCode co-author + model trailer to every commit.
Enable it once per clone:

```bash
just hooks       # git config core.hooksPath .githooks
```

## Quality gate

| Recipe | Command |
| ------ | ------- |
| `just lint` | `uv run ruff check .` |
| `just format-check` | `uv run ruff format --check .` |
| `just typecheck` | `uv run ty check` |
| `just test` | `uv run pytest -q` |
| `just check` | all of the above |

`prek.toml` wires the same four checks as a pre-commit hook (`prek install`, `prek run --all-files`).

## Sandbox workflow

The `planner` OpenCode agent runs inside a Docker Sandbox built from the companion
[opencode-sbx-sandbox](https://github.com/atorizva/opencode-sbx-sandbox) image. Sandboxes run in
`--clone` mode: the host repo is mounted **read-only** and the agent works on a private in-container
clone, so nothing it does can mutate your working tree. Changes flow back to the host as a pull request.

```bash
just sandbox-run     # create the sandbox, or re-attach if it already exists
just sandbox-delete  # tear the sandbox down
```

`sandbox-run` is create-or-reattach — the first invocation builds the sandbox, later ones re-attach
to the same agent (never a second instance). The image is pinned to a version tag
(`SBX_IMAGE=ghcr.io/atorizva/opencode-sbx-sandbox:v1.1.0`) and the sandbox name is fixed
(`SBX_NAME=agent-driven-py-project`); both are overridable via env vars.

Credentials (OpenCode API key, optional GitHub token) are stored once on the host with `sbx secret`
and proxied into the sandbox — never written to the repo or the sandbox filesystem. One-time host
setup (KVM, SSH agent, `sbx` sign-in) is covered by `just doctor` in the sandbox repo.

## Structure

```
src/agent_driven_py_project/   package
tests/                         tests
.opencode/                     OpenCode config + planner/worker agents
.githooks/                     versioned git hooks (enable with `just hooks`)
docs/agents/                   agent working docs (issue tracker, triage, domain)
docs/adr/                      architecture decision records
prek.toml                      pre-commit hooks
Justfile                       project + sandbox recipes
```

## License

MIT — see `LICENSE`.
