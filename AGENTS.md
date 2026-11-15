# Agent instructions — agent-driven-py-project

## Workflow

- The `planner` agent (primary) refines the plan and edits only agent/docs/config files.
- `worker` subagents implement in their own Git worktree under `.worktrees/<issue>-<slug>/`.
- One PR per `agent/<issue>-<slug>` branch. Workers do not merge, close others' work, change
  repo settings, or approve their own PRs.
- Before committing, run `just check` (ruff check, ruff format --check, ty check, pytest).

## Git commits

- Use Conventional Commits (`feat`, `fix`, `docs`, `chore`, `refactor`, `test`).
- Do not amend pushed commits. `--force-with-lease` is allowed only on your own branch.
- Add the OpenCode co-author trailer to every commit:

  `Co-authored-by: opencode-agent[bot] <opencode-agent[bot]@users.noreply.github.com>`

## Agent skills

### Issue tracker

Issues and specs are tracked in GitHub Issues using the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five canonical triage labels: `needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, and `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: use a root `GLOSSARY.md` and `docs/adr/`. See `docs/agents/domain.md`.
