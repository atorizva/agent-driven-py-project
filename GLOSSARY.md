# Glossary

Project terminology lives here (single-context).

- **Planner**: Interactive OpenCode primary agent that refines plans and may edit only agent/docs/config files.
- **Worker**: OpenCode subagent that implements changes in a worktree/branch and must not edit root agent/docs files.
- **Sandbox**: NVIDIA OpenShell container/VM boundary running the derived OpenCode image.
- **Quality gate**: `ruff check` + `ruff format --check` + `ty check` + `pytest`, run via `just check`.
