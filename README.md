# agent-driven-py-project

A Python project developed by an OpenCode agent running inside an NVIDIA OpenShell sandbox. The
agent works through a full learning loop: plan (planner) → implement (worker subagents in Git
worktrees) → verify (quality gate) → commit/PR.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) 0.13.8+ (manages CPython 3.15, dependencies, lockfile)
- `just` (task runner)
- Optional, for the sandbox workflow: `openshell` CLI + Docker, plus the companion
  [openpy-agent-sandbox](https://github.com/atorizva/openpy-agent-sandbox) repo.
- Optional, to watch the sandbox agent in a Herdr panel:
  [herdr-openshell](https://github.com/atorizva/herdr-openshell-integration).

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

The repository is uploaded one-way into an OpenShell sandbox at `/sandbox/repo`, where the
`planner` OpenCode agent runs. Changes flow back to the host through a pull request, not a bind
mount. Configuration (image, policy, provider profiles) lives in
[openpy-agent-sandbox](https://github.com/atorizva/openpy-agent-sandbox), cloned at a pinned tag
into gitignored `.openshell/`.

```bash
just setup-openshell   # clone pinned sandbox config into .openshell/
just sandbox-start     # create the sandbox with OpenCode as its main process
just sandbox-opencode  # attach to the already-running OpenCode agent
just sandbox-connect   # attach to the sandbox (same agent; no second instance)
just sandbox-delete    # tear the sandbox down
```

OpenCode is created as the sandbox's **main process**, not as a transient `sandbox exec`. With the
optional [herdr-openshell](https://github.com/atorizva/herdr-openshell-integration) plugin
installed, that process is mirrored into your Herdr panel, so you can watch and guide the agent
there instead of in the foreground terminal that started it. Without the plugin you still get the
plain attached terminal; nothing else changes.

Attaching a second time (`sandbox-opencode`, `sandbox-connect`) reuses that running process, so you
never end up with two agents in the same sandbox.

The image is pinned by digest (`OPENSHELL_IMAGE`, default `:latest` until the first GHCR publish;
then set `OPENSHELL_IMAGE=ghcr.io/atorizva/openpy-agent-sandbox@sha256:<digest>`).

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
