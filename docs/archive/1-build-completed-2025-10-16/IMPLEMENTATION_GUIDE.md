# Implementation Guide

This guide walks you through building the Time-Lab workbench from scratch. Follow these phases in order.

## Table of Contents

- [Phase 0: Prerequisites](#phase-0-prerequisites)
- [Phase 1: Foundation](#phase-1-foundation)
- [Phase 2: Core Scripts](#phase-2-core-scripts)
- [Phase 3: Rust Tools](#phase-3-rust-tools)
- [Phase 4: Python Tools](#phase-4-python-tools)
- [Phase 5: Quality & Safety](#phase-5-quality--safety)
- [Phase 6: Documentation & Schemas](#phase-6-documentation--schemas)
- [Phase 7: CI/CD](#phase-7-cicd)
- [Phase 8: Validation](#phase-8-validation)

---

## Phase 0: Prerequisites

### System Requirements

- **OS**: Linux, macOS, or WSL2 on Windows
- **Nix**: Install Nix with flakes enabled
- **Git**: Version control
- **Disk Space**: ~5GB for Nix store

### Install Nix with Flakes

```bash
# Install Nix (single-user recommended for development)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Enable flakes and nix-command
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << EOF
experimental-features = nix-command flakes
EOF
```

### Install Direnv (Optional but Recommended)

```bash
# On Linux
nix profile install nixpkgs#direnv

# Hook into your shell (.bashrc, .zshrc, etc.)
eval "$(direnv hook bash)"
```

---

## Phase 1: Foundation

### Step 1.1: Initialize Repository

```bash
# Create project directory
mkdir time-lab
cd time-lab
git init

# Create basic structure
mkdir -p docs nix scripts tools tests/fixtures secrets
touch README.md .gitignore .gitattributes Justfile
```

### Step 1.2: Create `.gitignore`

```bash
cat > .gitignore << 'EOF'
# Nix
result
result-*
.direnv/

# Secrets
secrets/
.env
.env.*
*.key
*.pem

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
*.egg-info/
.pytest_cache/

# Rust
target/
Cargo.lock  # For libraries; keep for binaries

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Temporary
*.tmp
*.log
.*.swp

# Keep structure but ignore artifact contents
**/outputs/**
!**/outputs/.gitkeep
EOF
```

### Step 1.3: Create `.gitattributes`

```bash
cat > .gitattributes << 'EOF'
# Treat all files as text by default
* text=auto

# Shell scripts
*.sh text eol=lf
*.bash text eol=lf

# Nix files
*.nix text eol=lf
flake.lock text eol=lf

# Markdown
*.md text eol=lf

# JSON
*.json text eol=lf

# YAML
*.yaml text eol=lf
*.yml text eol=lf

# Rust
*.rs text eol=lf
Cargo.toml text eol=lf

# Python
*.py text eol=lf
*.pyi text eol=lf
pyproject.toml text eol=lf

# Keep manifests readable in diffs
*.json diff=json
EOF
```

### Step 1.4: Create Initial `flake.nix`

```nix
{
  description = "Time-Lab: Reproducible AI Workbench";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Development shells
        devShells = {
          default = pkgs.mkShell {
            name = "time-lab-default";
            buildInputs = with pkgs; [
              # Core utilities
              just
              jq
              git

              # Shell tools
              shellcheck
              shfmt

              # Development
              direnv
            ];

            shellHook = ''
              echo "🧪 Time-Lab Development Environment"
              echo "Run 'just' to see available commands"
            '';
          };
        };

        # Packages (will add tools here later)
        packages = { };

        # Apps (will add here later)
        apps = { };

        # Checks for CI
        checks = { };
      }
    );
}
```

### Step 1.5: Initialize Flake Lock

```bash
# Generate flake.lock
nix flake lock

# Test that it works
nix flake show
nix develop --command echo "Success!"
```

### Step 1.6: Create `.envrc`

```bash
cat > .envrc << 'EOF'
# Load the default Nix development environment
use flake .

# Optional: Load local secrets if they exist
if [ -f secrets/.env.lab ]; then
  dotenv secrets/.env.lab
fi
EOF

# Allow direnv (if installed)
direnv allow || true
```

### Step 1.7: Create Initial `Justfile`

```makefile
# Justfile for common tasks

# List available commands
default:
    @just --list

# Create today's date structure
day:
    @echo "Creating today's workspace..."
    @bash scripts/today.sh

# Run LLM task with spec
ai spec:
    @echo "Running AI task: {{spec}}"
    @bash scripts/run_llm_task.sh "{{spec}}"

# Mine commits from GitHub repo
mine repo name limit="10":
    @echo "Mining commits from {{repo}}/{{name}}"
    @bash scripts/mine_commits.sh "{{repo}}" "{{name}}" "{{limit}}"

# Summarize a git commit
summ sha:
    @echo "Summarizing commit: {{sha}}"
    @bash scripts/summarize_diff.sh "{{sha}}"

# Run all checks (lint, format, test)
check:
    @echo "Running all checks..."
    @nix flake check

# Enter development shell
dev:
    @nix develop

# Update flake.lock
update:
    @nix flake update

# Clean build artifacts
clean:
    @rm -rf result result-*
    @echo "Cleaned build artifacts"
```

### Step 1.8: Commit Foundation

```bash
git add .
git commit -m "feat: initialize time-lab foundation

- Add flake.nix with default devShell
- Create directory structure
- Add .gitignore and .gitattributes
- Add Justfile for common tasks
- Add .envrc for direnv integration"
```

---

## Phase 2: Core Scripts

### Step 2.1: Create `scripts/today.sh`

This script creates the `YYYY/MM/DD` folder structure.

```bash
cat > scripts/today.sh << 'EOF'
#!/usr/bin/env bash
# Create today's workspace structure
# Usage: ./today.sh [YYYY-MM-DD]

set -Eeuo pipefail
IFS=$'\n\t'

# Get date (override with argument if provided)
if [ $# -eq 0 ]; then
  DATE_UTC=$(date -u +"%Y-%m-%d")
else
  DATE_UTC="$1"
fi

# Parse into components
YEAR=$(echo "$DATE_UTC" | cut -d'-' -f1)
MONTH=$(echo "$DATE_UTC" | cut -d'-' -f2)
DAY=$(echo "$DATE_UTC" | cut -d'-' -f3)

# Create structure
BASE_DIR="${YEAR}/${MONTH}/${DAY}"

echo "Creating workspace: $BASE_DIR"

mkdir -p "$BASE_DIR"/{ai-team/{specs,artifacts},analyzer/{inputs,outputs},knowledge/graph}

# Create README
cat > "$BASE_DIR/README.md" << INNER_EOF
# Workspace: $DATE_UTC

Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Structure

- \`ai-team/\` - LLM task specifications and outputs
- \`analyzer/\` - Data analysis inputs and results
- \`knowledge/\` - Notes, graphs, and insights

## Runs

See \`runs.csv\` for execution history.
INNER_EOF

# Create runs.csv if it doesn't exist
if [ ! -f "$BASE_DIR/runs.csv" ]; then
  echo "run_id,timestamp_start,timestamp_end,cmd,status" > "$BASE_DIR/runs.csv"
fi

# Update latest symlink
rm -f latest
ln -s "$BASE_DIR" latest

echo "✅ Workspace created: $BASE_DIR"
echo "   Symlinked: latest -> $BASE_DIR"
EOF

chmod +x scripts/today.sh
```

### Step 2.2: Create `scripts/run_llm_task.sh`

```bash
cat > scripts/run_llm_task.sh << 'EOF'
#!/usr/bin/env bash
# Run an LLM task from a spec file
# Usage: ./run_llm_task.sh <spec.json>

set -Eeuo pipefail
IFS=$'\n\t'

if [ $# -ne 1 ]; then
  echo "Usage: $0 <spec.json>" >&2
  exit 64
fi

SPEC_FILE="$1"

if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: Spec file not found: $SPEC_FILE" >&2
  exit 65
fi

# Validate spec (basic check for now)
if ! jq empty "$SPEC_FILE" 2>/dev/null; then
  echo "Error: Invalid JSON in spec file" >&2
  exit 65
fi

# Generate deterministic run ID
GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
FLAKE_LOCK_SHA=$(sha256sum flake.lock | cut -d' ' -f1)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SPEC_HASH=$(sha256sum "$SPEC_FILE" | cut -d' ' -f1)

RUN_ID=$(echo -n "${SPEC_HASH}${GIT_SHA}${FLAKE_LOCK_SHA}${TIMESTAMP}" | sha256sum | cut -d' ' -f1)

echo "🚀 Starting LLM task"
echo "   Run ID: $RUN_ID"
echo "   Spec: $SPEC_FILE"

# Determine output directory
SPEC_DIR=$(dirname "$SPEC_FILE")
ARTIFACTS_DIR="${SPEC_DIR}/../artifacts"
mkdir -p "$ARTIFACTS_DIR"

# Create run manifest
RUN_MANIFEST="$ARTIFACTS_DIR/run_${RUN_ID:0:8}.json"

cat > "$RUN_MANIFEST" << MANIFEST_EOF
{
  "run_id": "$RUN_ID",
  "timestamp_start": "$TIMESTAMP",
  "timestamp_end": null,
  "cmd": "$0 $*",
  "git_sha": "$GIT_SHA",
  "flake_lock_sha256": "$FLAKE_LOCK_SHA",
  "env": {
    "system": "$(uname -s)-$(uname -m)",
    "nix_version": "$(nix --version | head -1)"
  },
  "task": {
    "kind": "llm",
    "spec_path": "$SPEC_FILE",
    "spec_hash": "$SPEC_HASH"
  },
  "status": "running",
  "artifacts": []
}
MANIFEST_EOF

echo "   Manifest: $RUN_MANIFEST"

# TODO: Actual LLM execution goes here
# For now, just create a placeholder output
echo "⚠️  LLM execution not yet implemented"
echo "   This would call your LLM with the spec"

# Update manifest
TIMESTAMP_END=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg ts "$TIMESTAMP_END" \
   --arg status "ok" \
   '.timestamp_end = $ts | .status = $status' \
   "$RUN_MANIFEST" > "${RUN_MANIFEST}.tmp" && mv "${RUN_MANIFEST}.tmp" "$RUN_MANIFEST"

echo "✅ Task completed"
echo "   Output: $ARTIFACTS_DIR"
EOF

chmod +x scripts/run_llm_task.sh
```

### Step 2.3: Create Placeholder Scripts

```bash
# mine_commits.sh placeholder
cat > scripts/mine_commits.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "TODO: Implement git commit mining"
echo "Args: repo=$1 name=$2 limit=$3"
EOF
chmod +x scripts/mine_commits.sh

# summarize_diff.sh placeholder
cat > scripts/summarize_diff.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "TODO: Implement diff summarization"
echo "Args: sha=$1"
EOF
chmod +x scripts/summarize_diff.sh

# sync_latest.sh
cat > scripts/sync_latest.sh << 'EOF'
#!/usr/bin/env bash
# Update latest symlink to most recent date folder
set -Eeuo pipefail

LATEST_DIR=$(find . -maxdepth 3 -type d -regex '\./[0-9]\{4\}/[0-9]\{2\}/[0-9]\{2\}' | sort -r | head -1)

if [ -n "$LATEST_DIR" ]; then
  rm -f latest
  ln -s "$LATEST_DIR" latest
  echo "✅ Updated latest -> $LATEST_DIR"
else
  echo "⚠️  No date folders found"
fi
EOF
chmod +x scripts/sync_latest.sh
```

### Step 2.4: Test Scripts

```bash
# Test today.sh
./scripts/today.sh
ls -la latest/

# Test sync_latest.sh
./scripts/sync_latest.sh
```

### Step 2.5: Commit Scripts

```bash
git add scripts/
git commit -m "feat: add core automation scripts

- today.sh: Create YYYY/MM/DD structure
- run_llm_task.sh: Execute LLM tasks with manifests
- sync_latest.sh: Update latest symlink
- Placeholder scripts for mining and summarization"
```

---

## Phase 3: Rust Tools

### Step 3.1: Create Rust Extractor Tool

```bash
mkdir -p tools/rust_extractor/src

cat > tools/rust_extractor/Cargo.toml << 'EOF'
[package]
name = "rust_extractor"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
clap = { version = "4.0", features = ["derive"] }
EOF

cat > tools/rust_extractor/src/main.rs << 'EOF'
use anyhow::Result;
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Input file path
    #[arg(short, long)]
    input: String,

    /// Output file path
    #[arg(short, long)]
    output: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct ExtractedData {
    source: String,
    timestamp: String,
    items: Vec<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    println!("🦀 Rust Extractor");
    println!("   Input: {}", args.input);
    println!("   Output: {}", args.output);

    // Read input
    let content = fs::read_to_string(&args.input)?;

    // Process (placeholder - extract lines for now)
    let items: Vec<String> = content
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|s| s.to_string())
        .collect();

    // Create output
    let data = ExtractedData {
        source: args.input.clone(),
        timestamp: chrono::Utc::now().to_rfc3339(),
        items,
    };

    // Write JSON output
    let json = serde_json::to_string_pretty(&data)?;
    fs::write(&args.output, json)?;

    println!("✅ Extracted {} items", data.items.len());

    Ok(())
}
EOF
```

### Step 3.2: Add Rust to `flake.nix`

Update the `flake.nix` to add Rust development shell and build the tool:

```nix
# Add to outputs, inside the flake-utils.lib.eachDefaultSystem function
devShells = {
  default = pkgs.mkShell {
    # ... existing ...
  };

  # Add Rust development shell
  rust_dev = pkgs.mkShell {
    name = "time-lab-rust";
    buildInputs = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ];

    shellHook = ''
      echo "🦀 Rust Development Environment"
    '';
  };
};

packages = {
  # Build rust_extractor
  rust_extractor = pkgs.rustPlatform.buildRustPackage {
    pname = "rust_extractor";
    version = "0.1.0";
    src = ./tools/rust_extractor;
    cargoLock = {
      lockFile = ./tools/rust_extractor/Cargo.lock;
    };
  };
};
```

### Step 3.3: Generate Cargo.lock

```bash
cd tools/rust_extractor
nix develop ../../#rust_dev --command cargo build
cd ../..
```

### Step 3.4: Test Build

```bash
nix build .#rust_extractor
./result/bin/rust_extractor --help
```

### Step 3.5: Commit Rust Tool

```bash
git add tools/rust_extractor/ flake.nix
git commit -m "feat: add rust_extractor tool

- Basic CLI for data extraction
- Nix package definition in flake
- Rust devShell profile"
```

---

## Phase 4: Python Tools

### Step 4.1: Create Python Post-Processor

```bash
mkdir -p tools/py_post

cat > tools/py_post/pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=65.0"]
build-backend = "setuptools.build_meta"

[project]
name = "py-post"
version = "0.1.0"
description = "Post-processing tools for Time-Lab"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0",
    "click>=8.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=23.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[tool.black]
line-length = 100
target-version = ['py311']

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.mypy]
python_version = "3.11"
strict = true
EOF

cat > tools/py_post/py_post.py << 'EOF'
#!/usr/bin/env python3
"""Post-processing tool for Time-Lab artifacts."""

from pathlib import Path
from typing import Any
import json
import click
from pydantic import BaseModel, Field


class RunManifest(BaseModel):
    """Run manifest schema."""
    run_id: str
    timestamp_start: str
    timestamp_end: str | None = None
    cmd: str
    git_sha: str
    status: str


@click.command()
@click.option('--input', '-i', type=click.Path(exists=True), required=True)
@click.option('--output', '-o', type=click.Path(), required=True)
def process(input: str, output: str) -> None:
    """Process run manifest and extract insights."""
    click.echo(f"🐍 Python Post-Processor")
    click.echo(f"   Input: {input}")
    click.echo(f"   Output: {output}")

    # Read manifest
    with open(input, 'r') as f:
        data: dict[str, Any] = json.load(f)

    # Validate
    manifest: RunManifest = RunManifest(**data)

    # Process (placeholder)
    result: dict[str, Any] = {
        "run_id": manifest.run_id,
        "status": manifest.status,
        "processed_at": manifest.timestamp_end or manifest.timestamp_start,
    }

    # Write output
    with open(output, 'w') as f:
        json.dump(result, f, indent=2)

    click.echo(f"✅ Processed: {manifest.run_id[:8]}...")


if __name__ == '__main__':
    process()
EOF

chmod +x tools/py_post/py_post.py
```

### Step 4.2: Add Python to `flake.nix`

```nix
# Add to devShells
python_ml = pkgs.mkShell {
  name = "time-lab-python";
  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.virtualenv
  ];

  shellHook = ''
    echo "🐍 Python ML Environment"
    # Create venv if it doesn't exist
    if [ ! -d .venv ]; then
      python -m venv .venv
    fi
    source .venv/bin/activate
    pip install -q --upgrade pip
    pip install -q -e "tools/py_post[dev]"
  '';
};
```

### Step 4.3: Test Python Tool

```bash
nix develop .#python_ml --command python tools/py_post/py_post.py --help
```

### Step 4.4: Commit Python Tool

```bash
git add tools/py_post/ flake.nix
git commit -m "feat: add Python post-processing tool

- Basic CLI with click and pydantic
- Type-safe manifest processing
- Python devShell with venv setup"
```

---

## Phase 5: Quality & Safety

### Step 5.1: Add Pre-commit Configuration

```bash
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-toml
      - id: detect-private-key

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]

  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.9.0
    hooks:
      - id: shellcheck
EOF
```

### Step 5.2: Initialize Secrets Baseline

```bash
# Create .secrets.baseline
cat > .secrets.baseline << 'EOF'
{
  "version": "1.4.0",
  "plugins_used": [],
  "filters_used": [],
  "results": {},
  "generated_at": "2025-10-15T00:00:00Z"
}
EOF
```

### Step 5.3: Harden Shell Scripts

Update all shell scripts to include:

```bash
set -Eeuo pipefail
IFS=$'\n\t'
```

(Already done in above scripts)

### Step 5.4: Add Checks to `flake.nix`

```nix
checks = {
  # Shellcheck
  shellcheck = pkgs.runCommand "shellcheck" {
    buildInputs = [ pkgs.shellcheck ];
  } ''
    shellcheck ${./scripts}/*.sh
    touch $out
  '';

  # Nix format check
  nixfmt = pkgs.runCommand "nixfmt-check" {
    buildInputs = [ pkgs.alejandra ];
  } ''
    alejandra --check ${./.}
    touch $out
  '';
};
```

### Step 5.5: Commit Quality Tools

```bash
git add .pre-commit-config.yaml .secrets.baseline flake.nix
git commit -m "feat: add quality and safety tools

- Pre-commit hooks for formatting and linting
- detect-secrets for credential scanning
- Hardened shell scripts with strict mode
- Nix checks for CI integration"
```

---

## Phase 6: Documentation & Schemas

### Step 6.1: Create JSON Schemas

```bash
mkdir -p docs/schemas

cat > docs/schemas/run.schema.json << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://time-lab.local/schemas/run.schema.json",
  "title": "Run Manifest",
  "description": "Schema for execution run manifests",
  "type": "object",
  "required": [
    "run_id",
    "timestamp_start",
    "cmd",
    "git_sha",
    "flake_lock_sha256",
    "status"
  ],
  "properties": {
    "run_id": {
      "type": "string",
      "description": "Deterministic hash of run parameters",
      "pattern": "^[a-f0-9]{64}$"
    },
    "timestamp_start": {
      "type": "string",
      "format": "date-time",
      "description": "UTC timestamp when run started"
    },
    "timestamp_end": {
      "type": ["string", "null"],
      "format": "date-time",
      "description": "UTC timestamp when run ended"
    },
    "cmd": {
      "type": "string",
      "description": "Command that was executed"
    },
    "git_sha": {
      "type": "string",
      "description": "Git commit SHA",
      "pattern": "^[a-f0-9]{7,40}$"
    },
    "flake_lock_sha256": {
      "type": "string",
      "description": "SHA256 of flake.lock",
      "pattern": "^[a-f0-9]{64}$"
    },
    "env": {
      "type": "object",
      "description": "Environment information"
    },
    "task": {
      "type": "object",
      "description": "Task-specific metadata"
    },
    "model": {
      "type": "object",
      "description": "Model configuration (for LLM tasks)",
      "properties": {
        "name": { "type": "string" },
        "hash": { "type": "string" },
        "params": {
          "type": "object",
          "properties": {
            "temperature": { "type": "number" },
            "top_p": { "type": "number" },
            "seed": { "type": "integer" }
          }
        }
      }
    },
    "status": {
      "type": "string",
      "enum": ["running", "ok", "error", "cancelled"]
    },
    "artifacts": {
      "type": "array",
      "items": { "type": "string" },
      "description": "List of output artifact paths"
    }
  }
}
EOF

cat > docs/schemas/spec.schema.json << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://time-lab.local/schemas/spec.schema.json",
  "title": "Task Specification",
  "description": "Schema for task input specifications",
  "type": "object",
  "required": ["kind", "version"],
  "properties": {
    "kind": {
      "type": "string",
      "enum": ["llm", "analysis", "extraction", "mining"],
      "description": "Type of task"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+$",
      "description": "Spec version"
    },
    "inputs": {
      "type": "object",
      "description": "Task-specific inputs"
    },
    "config": {
      "type": "object",
      "description": "Task configuration"
    }
  }
}
EOF
```

### Step 6.2: Create Decision Registry

```bash
cat > docs/DECISIONS.md << 'EOF'
# Architectural Decision Records (ADR)

## Format

Each decision should include:
- **ID**: Unique identifier (D001, D002, etc.)
- **Date**: When decision was made
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Context**: What is the issue we're trying to solve?
- **Decision**: What did we decide?
- **Consequences**: What becomes easier or harder?

---

## D001: VM on Windows Host, No Docker

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Development on Windows requires Linux tooling for Nix.

**Decision**: Run in WSL2/VM rather than Docker containers.

**Consequences**:
- ✅ Full Nix support
- ✅ Better file system performance
- ❌ Requires WSL2 setup
- ❌ More resource overhead than native Linux

---

## D002: Single Monorepo

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need to manage multiple tools (Rust, Python, scripts) for AI experiments.

**Decision**: Use single monorepo with one `flake.lock` for all dependencies.

**Consequences**:
- ✅ One source of truth for versions
- ✅ Simplified cross-tool integration
- ✅ Easier to maintain
- ❌ Larger checkout size
- ❌ All tools share same dependency versions

---

## D003: Date Tree YYYY/MM/DD

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need intuitive organization for daily experimental work.

**Decision**: Use `YYYY/MM/DD` folder structure for all artifacts.

**Consequences**:
- ✅ Natural chronological navigation
- ✅ Easy to find "what did I do on date X"
- ✅ Works well with file explorers
- ❌ Deeper nesting than flat structure
- ❌ Requires tooling to create folders

---

## D004: Run Manifests Must Follow Schema

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need reproducibility and traceability of all executions.

**Decision**: Every run must produce `run.json` following `run.schema.json`.

**Consequences**:
- ✅ Structured provenance tracking
- ✅ Machine-readable execution history
- ✅ Can validate and query manifests
- ❌ Additional complexity in scripts
- ❌ Must maintain schema

---

## D005: Model Calls Logged with Params + Seed

**Date**: 2025-10-15
**Status**: Accepted

**Context**: LLM outputs are non-deterministic without parameter tracking.

**Decision**: Log `temperature`, `top_p`, `seed`, `max_tokens`, model hash for all LLM calls.

**Consequences**:
- ✅ Reproducible LLM experiments (when seed is supported)
- ✅ Can debug unexpected outputs
- ❌ Requires instrumentation of all LLM calls
- ❌ Not all models support all parameters

---

## D006: Existing Projects Wrapped via DevShells

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Want to integrate existing Rust/Python projects without rewriting.

**Decision**: Use Nix devShells to provide environments; don't require full nixification initially.

**Consequences**:
- ✅ Lower barrier to adoption
- ✅ Can gradually nixify projects
- ✅ Familiar workflows (cargo, pip) still work
- ❌ Less hermetic than pure Nix builds
- ❌ May have impurities (network, system deps)

---

## Template for New Decisions

```markdown
## D00X: Short Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated

**Context**: What is the situation and problem?

**Decision**: What did we decide to do?

**Consequences**:
- ✅ Positive consequence
- ❌ Negative consequence
```
EOF
```

### Step 6.3: Create SOPS Guide

```bash
cat > docs/SOPS.md << 'EOF'
# Secrets Management with SOPS

## Overview

We use [sops-nix](https://github.com/Mic92/sops-nix) for managing secrets in Nix.

## Quick Start

### 1. Install SOPS

```bash
nix profile install nixpkgs#sops
```

### 2. Generate Age Key

```bash
mkdir -p secrets
age-keygen -o secrets/age-key.txt
chmod 600 secrets/age-key.txt
```

**⚠️ IMPORTANT**: Add `secrets/age-key.txt` to `.gitignore` (already done).

### 3. Create Secrets File

```bash
# Get your public key
cat secrets/age-key.txt | grep "public key"

# Create .sops.yaml
cat > .sops.yaml << EOF
keys:
  - &admin YOUR_PUBLIC_KEY_HERE
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: *admin
EOF

# Create encrypted secrets
sops secrets/lab.yaml
```

### 4. Access Secrets in Nix

```nix
# In flake.nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = { self, nixpkgs, sops-nix, ... }: {
    # Add sops to devShell
  };
}
```

## Best Practices

1. **Never commit unencrypted secrets**
2. **Use `.env` files for local development** (git-ignored)
3. **Use sops for production secrets**
4. **Rotate keys periodically**
5. **Document what secrets are needed** (but not their values!)

## Secrets Needed

Document here what secrets the project needs (without values):

- `OPENAI_API_KEY` - OpenAI API key for LLM tasks
- `GITHUB_TOKEN` - GitHub PAT for API access (mining commits)
- `HF_TOKEN` - Hugging Face token for model downloads

## Local Development

For local development, create `secrets/.env.lab`:

```bash
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

This file is automatically loaded by `.envrc`.
EOF
```

### Step 6.4: Commit Documentation

```bash
git add docs/
git commit -m "docs: add schemas, decisions, and SOPS guide

- JSON schemas for run manifests and specs
- Architectural decision records (D001-D006)
- SOPS secrets management guide
- Document required secrets"
```

---

## Phase 7: CI/CD

### Step 7.1: Create GitHub Actions Workflow

```bash
mkdir -p .github/workflows

cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  nix-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v24
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes

      - name: Run flake check
        run: nix flake check

      - name: Build rust_extractor
        run: nix build .#rust_extractor

      - name: Test scripts
        run: |
          nix develop --command shellcheck scripts/*.sh

  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install pre-commit
        run: pip install pre-commit

      - name: Run pre-commit
        run: pre-commit run --all-files
EOF
```

### Step 7.2: Add Cachix (Optional)

For faster CI builds:

```yaml
# Add after "Install Nix" step
      - name: Setup Cachix
        uses: cachix/cachix-action@v12
        with:
          name: your-cache-name
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
```

### Step 7.3: Commit CI Configuration

```bash
git add .github/
git commit -m "ci: add GitHub Actions workflow

- Run nix flake check on push/PR
- Build rust_extractor
- Run shellcheck on all scripts
- Run pre-commit hooks"
```

---

## Phase 8: Validation

### Step 8.1: Run Acceptance Tests

Go through each item in the acceptance checklist:

```bash
# 1. Development environment
nix develop --command bash -c "which rust && which python && which jq && which just"

# 2. Build rust_extractor
nix build .#rust_extractor
./result/bin/rust_extractor --help

# 3. Create daily tree
just day
ls -la latest/

# 4. Run AI task (will be placeholder for now)
mkdir -p latest/ai-team/specs
echo '{"kind":"llm","version":"1.0"}' > latest/ai-team/specs/demo.json
just ai spec=latest/ai-team/specs/demo.json

# 5 & 6. Mining and summarization (placeholders)
just mine repo=test name=repo limit=5
just summ sha=abc123

# 7. Flake check
nix flake check

# 8. Shellcheck
nix develop --command shellcheck scripts/*.sh
```

### Step 8.2: Create Integration Test

```bash
mkdir -p tests/integration

cat > tests/integration/test_workflow.sh << 'EOF'
#!/usr/bin/env bash
# Integration test: End-to-end workflow

set -Eeuo pipefail

echo "🧪 Running integration tests..."

# Test 1: Create workspace
echo "Test 1: Create workspace"
./scripts/today.sh 2025-10-15
[ -d "2025/10/15" ] || exit 1
echo "✅ Pass"

# Test 2: Run LLM task
echo "Test 2: Run LLM task"
mkdir -p 2025/10/15/ai-team/specs
echo '{"kind":"llm","version":"1.0","inputs":{}}' > 2025/10/15/ai-team/specs/test.json
./scripts/run_llm_task.sh 2025/10/15/ai-team/specs/test.json
[ -f 2025/10/15/ai-team/artifacts/run_*.json ] || exit 1
echo "✅ Pass"

# Test 3: Validate manifest
echo "Test 3: Validate manifest"
MANIFEST=$(ls 2025/10/15/ai-team/artifacts/run_*.json | head -1)
jq -e '.run_id' "$MANIFEST" > /dev/null || exit 1
echo "✅ Pass"

echo "🎉 All tests passed!"
EOF

chmod +x tests/integration/test_workflow.sh
```

### Step 8.3: Run Tests

```bash
nix develop --command bash tests/integration/test_workflow.sh
```

### Step 8.4: Update Main README

Update the main `README.md` with the current status and any findings from validation.

### Step 8.5: Final Commit

```bash
git add tests/
git commit -m "test: add integration tests and validation

- End-to-end workflow test
- Validation of all acceptance criteria
- Update README with current status"
```

---

## Next Steps

After completing these phases, you'll have a solid foundation. Next priorities:

1. **Implement LLM Integration**
   - Add actual LLM API calls (OpenAI, Anthropic, local models)
   - Implement spec-driven task execution
   - Add model parameter logging

2. **Git Mining Tools**
   - Implement `mine_commits.sh` with GitHub API
   - Add commit diff analysis
   - Create summarization pipeline

3. **Enhanced Tooling**
   - Add more Rust analysis tools
   - Expand Python post-processing
   - Create visualization tools

4. **AI-Team Integration**
   - Freeze `spec.json` schema
   - Define return codes and contracts
   - Create multi-agent workflows

5. **Advanced Features**
   - Network isolation (--offline by default)
   - Shallow git clones for efficiency
   - Advanced caching strategies

---

## Troubleshooting

### Nix Issues

**Problem**: `error: experimental feature 'nix-command' is disabled`

**Solution**:
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

**Problem**: `error: getting status of '/nix/store/...': No such file or directory`

**Solution**: Run `nix-store --verify --check-contents --repair`

### Direnv Issues

**Problem**: `.envrc is blocked`

**Solution**: Run `direnv allow`

### Python Issues

**Problem**: Module not found after pip install

**Solution**: Ensure you're in the venv: `source .venv/bin/activate`

---

## Additional Resources

- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learn Nix deeply
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes) - Flakes reference
- [Just Documentation](https://github.com/casey/just) - Task runner guide
- [Structurizr](https://structurizr.com/) - Architecture diagrams
- [ADR GitHub](https://adr.github.io/) - Decision record best practices

---

**Status**: 📋 Implementation Guide v1.0
**Last Updated**: 2025-10-15
