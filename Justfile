set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# --- OpenShell sandbox integration ---
OPENSHELL_REPO := "git@github.com:atorizva/openpy-agent-sandbox.git"
OPENSHELL_REF := env_var_or_default("OPENSHELL_REF", "v1.0.0")
# Pin to @sha256:<digest> after the first GHCR publish.
OPENSHELL_IMAGE := env_var_or_default("OPENSHELL_IMAGE", "ghcr.io/atorizva/openpy-agent-sandbox:latest")

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

# Clone the pinned sandbox config repo into gitignored .openshell/
setup-openshell:
    @test -d .openshell || git clone --depth 1 --branch {{OPENSHELL_REF}} {{OPENSHELL_REPO}} .openshell

sandbox-start: setup-openshell
    OPENSHELL_IMAGE="{{OPENSHELL_IMAGE}}" just -f .openshell/Justfile start "$(pwd)"

sandbox-opencode: setup-openshell
    just -f .openshell/Justfile opencode

sandbox-connect: setup-openshell
    just -f .openshell/Justfile connect

sandbox-delete: setup-openshell
    just -f .openshell/Justfile delete
