# agent-driven-py-project

A Python project developed by an OpenCode agent running inside an NVIDIA OpenShell sandbox. The
agent works through a full learning loop: plan (planner) → implement (worker subagents in Git
worktrees) → verify (quality gate) → commit/PR.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) 0.13.8+ (manages CPython 3.15, dependencies, lockfile)
- `just` (task runner)
- Optional, for the sandbox workflow: `openshell` CLI + Docker, plus the companion
  [openpy-agent-sandbox](https://github.com/atorizva/openpy-agent-sandbox) repo.

## Getting started

```bash
uv sync          # install CPython 3.15 + dev dependencies
just check       # ruff check, ruff format --check, ty check, pytest
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
just sandbox-start     # seed this repo into a sandbox and open OpenCode
just sandbox-opencode  # re-open OpenCode (interactive) inside the sandbox
just sandbox-connect   # attach to the sandbox shell
just sandbox-delete    # tear the sandbox down
```

The image is pinned by digest (`OPENSHELL_IMAGE`, default `:latest` until the first GHCR publish;
then set `OPENSHELL_IMAGE=ghcr.io/atorizva/openpy-agent-sandbox@sha256:<digest>`).

## Structure

```
src/agent_driven_py_project/   package
tests/                         tests
.opencode/                     OpenCode config + planner/worker agents
docs/agents/                   agent working docs (issue tracker, triage, domain)
docs/adr/                      architecture decision records
prek.toml                      pre-commit hooks
Justfile                       project + sandbox recipes
```

## License

MIT — see `LICENSE`.
