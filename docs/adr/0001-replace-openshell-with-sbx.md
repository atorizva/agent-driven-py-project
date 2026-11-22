# ADR-0001: Replace OpenShell with Docker Sandboxes (SBX)

**Status:** accepted

**Date:** 2026-11-22

## Context

The template originally ran its `planner` agent inside an NVIDIA OpenShell sandbox, with sandbox
configuration (image, policy, provider profiles) living in a separate companion repo
(`openpy-agent-sandbox`) cloned at a pinned tag into a gitignored `.openshell/` directory.

OpenShell proved harder to use during development than Docker Sandboxes (`sbx`). A new companion
repo, `opencode-sbx-sandbox`, builds and publishes an OpenCode agent image to GHCR with network
policy, credential proxying, and SSH-agent forwarding baked into the image itself. That removes the
need for a per-project config clone: consuming the sandbox is a single `sbx run <image> --clone .`.

## Decision

Replace the OpenShell workflow with Docker Sandboxes (`sbx`):

- Drop `setup-openshell` and the gitignored `.openshell/` config clone.
- Add two recipes — `sandbox-run` (`sbx run $SBX_IMAGE --clone . --name $SBX_NAME`, create-or-reattach)
  and `sandbox-delete` (`sbx rm $SBX_NAME`).
- Pin `SBX_IMAGE` to a versioned GHCR tag (`v1.1.0`), overridable via env.
- Keep the planner/worker worktree + one-PR-per-branch flow unchanged; workers push to GitHub origin
  and open PRs as before. The sandbox only changes the execution boundary, not the development workflow.
- Credentials are one-time host setup via `sbx secret`; the template documents, not duplicates, this.

## Consequences

- Easier to start: no config repo to clone or pin separately.
- Sandbox lifecycle collapses to create-or-reattach (`run`) plus teardown (`delete`).
- The optional Herdr panel integration is dropped (no SBX equivalent).
- `SBX_NAME` must satisfy `sbx` naming rules (ASCII letters/numbers/hyphens/periods — no underscores).
- One-time host setup (KVM, SSH agent, `sbx` sign-in, secrets) is still required before the first run.
