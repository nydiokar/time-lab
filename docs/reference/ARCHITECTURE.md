# Architecture

This document describes the design patterns, principles, and structure of Time-Lab.

## Table of Contents

- [System Overview](#system-overview)
- [Core Principles](#core-principles)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Reproducibility Model](#reproducibility-model)

---

## System Overview

Time-Lab is a **reproducible AI workbench** that treats every experiment as a deterministic function:

```
f(spec, environment, model) â†’ artifacts + manifest
```

Where:
- **spec**: Input specification (JSON)
- **environment**: Pinned Nix environment (flake.lock + git SHA)
- **model**: AI model with parameters (including seed)
- **artifacts**: Output files (JSON, markdown, etc.)
- **manifest**: Provenance record (run.json)

### Design Philosophy

Inspired by the [time-2025 repository](https://github.com/meta-introspector/time-2025), Time-Lab follows these patterns:

1. **Date-First Organization**: YYYY/MM/DD structure mirrors research workflow
2. **Polyglot by Design**: Rust for performance, Python for ML, Nix for reproducibility
3. **Artifact-Centric**: Outputs are first-class; not just side effects
4. **Monorepo Pragmatism**: One repo, one lockfile, many tools

---

## Core Principles

### 1. Determinism Where Possible

**Goal**: Given the same inputs, produce the same outputs.

**Implementation**:
- Pin all dependencies in `flake.lock`
- Record git SHA in manifests
- Log random seeds for non-deterministic operations
- Use UTC timestamps (no local timezone ambiguity)

**Limitations**:
- LLM APIs may change behavior
- Network resources may become unavailable
- Hardware differences can affect floating-point math

### 2. Traceability Always

**Goal**: Every artifact can be traced back to its inputs and environment.

**Implementation**:
- Every run produces a `run.json` manifest
- Manifests include:
  - Deterministic run ID (hash of all inputs)
  - Git commit SHA
  - Flake lock hash
  - Command executed
  - Timestamps (start/end)
  - Model parameters
  - Artifact paths

### 3. Isolation via Profiles

**Goal**: Different workflows don't interfere with each other.

**Implementation**:
- Multiple Nix devShells (`default`, `rust_dev`, `python_ml`, etc.)
- Each profile provides specific tools
- Profiles can be composed (inherit from default)
- Subdirectories can override via `.envrc`

### 4. Safety by Default

**Goal**: Prevent accidental data loss, secret leaks, or destructive operations.

**Implementation**:
- Secrets directory in `.gitignore`
- Pre-commit hooks detect credentials
- Hardened shell scripts (`set -Eeuo pipefail`)
- Non-root execution
- Explicit `allow_net` flags for network access

---

## Component Architecture

### High-Level Structure

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    Nix Flake (flake.nix)                â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚  DevShells   â”‚  â”‚   Packages   â”‚  â”‚     Apps     â”‚  â”‚
â”‚  â”‚  (profiles)  â”‚  â”‚  (built bins)â”‚  â”‚  (runnable)  â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â”‚                  â”‚                  â”‚
           â–¼                  â–¼                  â–¼
    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
    â”‚  Scripts â”‚       â”‚   Tools  â”‚      â”‚   Nix    â”‚
    â”‚          â”‚       â”‚          â”‚      â”‚  Modules â”‚
    â”‚ today.sh â”‚       â”‚  rust_   â”‚      â”‚          â”‚
    â”‚ run_llm  â”‚       â”‚ extractorâ”‚      â”‚ overlays â”‚
    â”‚ mine.sh  â”‚       â”‚  py_post â”‚      â”‚          â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â”‚                  â”‚
           â–¼                  â–¼
    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
    â”‚      YYYY/MM/DD/             â”‚
    â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
    â”‚  â”‚ ai-team/              â”‚   â”‚
    â”‚  â”‚  â”œâ”€â”€ specs/           â”‚   â”‚
    â”‚  â”‚  â””â”€â”€ artifacts/       â”‚   â”‚
    â”‚  â”‚       â””â”€â”€ run.json    â”‚   â”‚
    â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
    â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
    â”‚  â”‚ analyzer/             â”‚   â”‚
    â”‚  â”‚  â”œâ”€â”€ inputs/          â”‚   â”‚
    â”‚  â”‚  â””â”€â”€ outputs/         â”‚   â”‚
    â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
    â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
    â”‚  â”‚ knowledge/            â”‚   â”‚
    â”‚  â”‚  â”œâ”€â”€ notes.md         â”‚   â”‚
    â”‚  â”‚  â””â”€â”€ graph/           â”‚   â”‚
    â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Component Descriptions

#### 1. Nix Flake (`flake.nix`)

**Purpose**: Declarative environment and package definitions.

**Responsibilities**:
- Define development shells (profiles)
- Build Rust and Python tools
- Provide Nix packages (overlays)
- Define CI checks
- Pin all dependencies

**Key Attributes**:
```nix
{
  devShells = { default, rust_dev, python_ml, ... };
  packages = { rust_extractor, py_post, ... };
  apps = { llm-task, mine-commits, ... };
  checks = { shellcheck, nixfmt, ... };
}
```

#### 2. Scripts (`scripts/`)

**Purpose**: High-level automation for common workflows.

**Characteristics**:
- Written in Bash
- Use strict error handling (`set -Eeuo pipefail`)
- Generate `run.json` manifests
- Call tools (Rust/Python) for heavy lifting
- Update symlinks and indices

**Examples**:
- `today.sh`: Create date folder structure
- `run_llm_task.sh`: Execute LLM with spec
- `mine_commits.sh`: Fetch git commits from GitHub
- `summarize_diff.sh`: Analyze commit diffs

#### 3. Tools (`tools/`)

**Purpose**: Compiled binaries and libraries for specific tasks.

**Rust Tools** (`tools/rust_extractor/`):
- Fast data extraction
- Parsing and transformation
- System-level operations
- Built with `cargo` and packaged via `rustPlatform.buildRustPackage`

**Python Tools** (`tools/py_post/`):
- ML model inference
- Data post-processing
- JSON schema validation
- Built with `pip` and packaged via `buildPythonPackage` or venv

#### 4. Nix Modules (`nix/`)

**Purpose**: Reusable Nix code and overlays.

**Examples**:
- `overlays.nix`: Package overlays for custom versions
- `poetry2nix.nix`: Python packaging via poetry2nix
- `modules/`: Reusable NixOS/home-manager modules

#### 5. Date-Organized Artifacts (`YYYY/MM/DD/`)

**Purpose**: Store all experimental outputs chronologically.

**Structure**:
```
2025/10/15/
â”œâ”€â”€ README.md          # Day summary
â”œâ”€â”€ runs.csv           # Execution log
â”œâ”€â”€ ai-team/
â”‚   â”œâ”€â”€ specs/         # Input specifications
â”‚   â””â”€â”€ artifacts/     # Outputs + manifests
â”œâ”€â”€ analyzer/
â”‚   â”œâ”€â”€ inputs/        # Data to analyze
â”‚   â””â”€â”€ outputs/       # Analysis results
â””â”€â”€ knowledge/
    â”œâ”€â”€ notes.md       # Observations
    â””â”€â”€ graph/         # Knowledge graphs
```

---

## Data Flow

### 1. LLM Task Execution

```
User
  â”‚
  â”‚ just ai spec=path/to/spec.json
  â–¼
Justfile
  â”‚
  â”‚ calls scripts/run_llm_task.sh
  â–¼
run_llm_task.sh
  â”‚
  â”œâ”€ Read spec.json
  â”œâ”€ Validate against schema
  â”œâ”€ Generate deterministic run_id
  â”œâ”€ Create run.json manifest
  â”‚
  â”‚ calls nix run .#llm-task
  â–¼
LLM Task App (Rust or Python)
  â”‚
  â”œâ”€ Load model
  â”œâ”€ Execute with spec
  â”œâ”€ Log parameters (seed, temp, etc.)
  â”œâ”€ Write outputs to artifacts/
  â”‚
  â”‚ returns to run_llm_task.sh
  â–¼
run_llm_task.sh
  â”‚
  â”œâ”€ Update run.json with status
  â”œâ”€ Record artifact paths
  â”œâ”€ Update runs.csv
  â”œâ”€ Sync latest/ symlink
  â–¼
Artifacts
  YYYY/MM/DD/ai-team/artifacts/
  â”œâ”€â”€ run_abc123.json
  â”œâ”€â”€ output.jsonl
  â””â”€â”€ log.txt
```

### 2. Commit Mining Workflow

```
User
  â”‚
  â”‚ just mine repo=owner name=repo limit=10
  â–¼
mine_commits.sh
  â”‚
  â”œâ”€ Call GitHub API
  â”œâ”€ Fetch commit list
  â”‚
  â”‚ for each commit:
  â”‚
  â”‚ calls summarize_diff.sh
  â–¼
summarize_diff.sh
  â”‚
  â”œâ”€ Fetch commit diff
  â”œâ”€ Extract changes
  â”‚
  â”‚ calls rust_extractor
  â–¼
rust_extractor
  â”‚
  â”œâ”€ Parse diff
  â”œâ”€ Extract files/changes
  â”œâ”€ Output structured JSON
  â”‚
  â”‚ returns to summarize_diff.sh
  â–¼
summarize_diff.sh
  â”‚
  â”‚ calls py_post
  â–¼
py_post
  â”‚
  â”œâ”€ Analyze patterns
  â”œâ”€ Generate summary
  â”œâ”€ Create analysis_summary.md
  â–¼
Artifacts
  YYYY/MM/DD/analyzer/outputs/
  â”œâ”€â”€ commit_abc123/
  â”‚   â”œâ”€â”€ diff_stats.txt
  â”‚   â”œâ”€â”€ full_diff.txt
  â”‚   â””â”€â”€ analysis_summary.md
```

---

## Reproducibility Model

### Deterministic Run ID

Every execution gets a unique, deterministic ID:

```bash
run_id = SHA256(
  spec_hash +
  git_sha +
  flake_lock_sha +
  utc_timestamp
)
```

**Why each component?**

- `spec_hash`: Input specification
- `git_sha`: Exact code version
- `flake_lock_sha`: Exact dependencies
- `utc_timestamp`: Temporal uniqueness (prevents collisions)

**Note**: Timestamp makes the ID unique per run, but the combination allows tracking "same inputs at different times".

### Environment Pinning

```
flake.lock
  â”œâ”€â”€ nixpkgs revision (e.g., nixos-unstable@abc123)
  â”œâ”€â”€ Rust toolchain version
  â”œâ”€â”€ Python version
  â””â”€â”€ All dependency SHAs
```

To update:
```bash
nix flake update        # Update all
nix flake lock --update-input nixpkgs  # Update specific input
```

### Model Reproducibility

For LLM tasks:

```json
{
  "model": {
    "name": "ollama:qwen2.5:7b",
    "hash": "sha256-...",
    "params": {
      "temperature": 0.2,
      "top_p": 0.95,
      "seed": 1234,
      "max_tokens": 2048
    }
  }
}
```

**Limitations**:
- API models (OpenAI, Anthropic) may silently update
- Not all models support seeding
- Quantization can introduce non-determinism

**Best Practices**:
- Use local models when possible (Ollama, LlamaCpp)
- Pin model versions explicitly
- Log model file hashes
- Document when reproducibility is not possible

---
