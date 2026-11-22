set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# --- Docker Sandbox (SBX) integration ---
SBX_IMAGE := env_var_or_default("SBX_IMAGE", "ghcr.io/atorizva/opencode-sbx-sandbox:v1.1.0")
SBX_NAME := env_var_or_default("SBX_NAME", "agent-driven-py-project")

default:
    @just --list

# --- Project recipes ---

sync:
    uv sync

lint:
    uv run ruff check .

format:
    uv run ruff format .

format-check:
    uv run ruff format --check .

typecheck:
    uv run ty check

test:
    uv run pytest -q

# Full quality gate
check: lint format-check typecheck test

# --- Git hooks ---

# Enable the versioned hooks in .githooks/ (run once per clone).
hooks:
    git config core.hooksPath .githooks

# --- Sandbox integration ---

# Create the sandbox from the image, or re-attach if it already exists.
# Clone mode: host repo mounted read-only, agent works on a private in-container clone.
sandbox-run:
    sbx run "{{SBX_IMAGE}}" --clone . --name "{{SBX_NAME}}"

# Tear the sandbox down.
sandbox-delete:
    sbx rm "{{SBX_NAME}}"
