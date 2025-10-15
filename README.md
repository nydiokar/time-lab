# Time-Lab: Reproducible AI Workbench

A **deterministic, date-organized AI experimentation environment** built on Nix, inspired by daily research workflows. Every experiment is reproducible, every artifact is timestamped, and every run is traceable.

## Philosophy

- **Reproducibility First**: Pin everything - Nix packages, model versions, random seeds
- **Date-Organized**: Natural `YYYY/MM/DD` folder structure mirrors how research happens
- **Artifact-Centric**: Every run produces a manifest + artifacts, not just stdout
- **Monorepo**: One repository, one lockfile, multiple tool profiles
- **Nix-Native**: All execution happens inside Nix devshells or via `nix run`

## Quick Start

```bash
# Enter development environment
nix develop

# Create today's workspace
just day

# Run an LLM task
just ai spec=2025/10/15/ai-team/specs/demo.json

# Mine commits from a repo
just mine repo=owner name=repo limit=10

# Summarize a git diff
just summ sha=abcd123
```

## Repository Structure

```
time-lab/
├── flake.nix              # Nix flake with all environments and tools
├── flake.lock             # Pinned dependencies
├── Justfile               # Common task runner commands
├── .envrc                 # Direnv integration (use flake .)
├── .gitignore
├── .gitattributes
│
├── docs/                  # Project documentation
│   ├── IMPLEMENTATION_GUIDE.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT_WORKFLOW.md
│   ├── DECISIONS.md       # Architectural Decision Records
│   ├── SOPS.md           # Secrets management guide
│   └── schemas/
│       ├── run.schema.json
│       └── spec.schema.json
│
├── scripts/               # Shell automation
│   ├── today.sh          # Create YYYY/MM/DD structure
│   ├── run_llm_task.sh   # Execute LLM with spec
│   ├── mine_commits.sh   # Fetch & analyze git commits
│   ├── summarize_diff.sh # Generate commit analysis
│   └── sync_latest.sh    # Update latest/ symlinks
│
├── tools/                 # Custom built tools
│   ├── rust_extractor/   # Rust-based data extraction
│   │   ├── Cargo.toml
│   │   └── src/main.rs
│   └── py_post/          # Python post-processing
│       ├── pyproject.toml
│       └── py_post.py
│
├── nix/                   # Nix modules and overlays
│   ├── overlays.nix
│   └── poetry2nix.nix
│
├── secrets/               # NOT IN GIT - local secrets
│   └── .env.lab
│
├── tests/                 # Integration tests
│   └── fixtures/         # Test data
│
└── YYYY/                  # Date-organized artifacts
    └── MM/
        └── DD/
            ├── README.md
            ├── ai-team/
            │   ├── specs/      # Input specifications
            │   └── artifacts/  # Output from runs
            ├── analyzer/
            │   ├── inputs/
            │   └── outputs/
            └── knowledge/
                ├── notes.md
                └── graph/
```

## Core Concepts

### 1. Run Manifests

Every execution produces a `run.json` manifest capturing:
- Deterministic run ID (hash of spec + git state + flake.lock + timestamp)
- Git SHA and flake.lock hash
- Model parameters (temperature, seed, etc.)
- Input/output artifact paths
- Execution timing and status

### 2. Date Organization

Artifacts are stored in `YYYY/MM/DD/` folders:
- Mirrors natural research workflow
- Easy to find "what did I do on X date"
- `latest/` symlink points to most recent
- `runs.csv` tracks all executions

### 3. Profile Isolation

Multiple Nix devShell profiles for different workflows:
- `rust_analyzer` - Rust development with clippy, rustfmt
- `python_ml` - Python with ML libraries
- `data_mining` - Git analysis and data extraction
- `default` - Common tools (jq, just, shellcheck)

### 4. Deterministic Execution

- UTC timestamps everywhere
- Log random seeds for model calls
- Record model file hashes/etags
- Pin all dependencies in flake.lock
- Optional: run with `--offline` by default

## Key Features

✅ **Reproducible Builds**: Nix ensures same inputs → same outputs  
✅ **Provenance Tracking**: `git describe` + `nix flake metadata` in manifests  
✅ **Schema Validation**: JSON schemas for specs and run manifests  
✅ **Pre-commit Hooks**: black, ruff, mypy, shellcheck, detect-secrets  
✅ **CI/CD Ready**: GitHub Actions workflow with `nix flake check`  
✅ **Secrets Management**: sops-nix integration (or `.env` files)  
✅ **Safety First**: Non-root execution, hardened shell scripts

## Development Workflow

1. **Start Your Day**
   ```bash
   just day  # Creates YYYY/MM/DD structure
   ```

2. **Run Experiments**
   ```bash
   just ai spec=path/to/spec.json
   # Outputs: YYYY/MM/DD/ai-team/artifacts/run.json + results
   ```

3. **Review Artifacts**
   ```bash
   cat latest/run.json | jq .
   ```

4. **Commit Your Work**
   ```bash
   git add .
   git commit -m "feat: experiment with X"
   # Pre-commit hooks run automatically
   ```

## Design Principles

Derived from analyzing the [time-2025 repository](https://github.com/meta-introspector/time-2025/tree/e96113fb96945452f2e9472820f0a0e5ff25de57/09):

1. **Embrace Daily Organization**: Date folders work naturally
2. **Mix Languages Freely**: Rust + Python + Nix + Shell all coexist
3. **Document as You Go**: Markdown files alongside code
4. **Keep Exploratory Work**: Don't delete experiments
5. **Use Nix for Reproducibility**: But pragmatically (not everything needs to be pure)

## Documentation Structure

```
docs/
├── 0-start/           👋 New? Start here
│   └── GETTING_STARTED.md
├── 1-build/           🔨 Building the system
│   └── IMPLEMENTATION_GUIDE.md
├── 2-use/             🚀 Daily operations
│   └── WORKFLOW.md
├── 3-extend/          🔧 Adding features
│   └── EXTENSION_GUIDE.md
├── reference/         📖 Look things up
│   ├── GLOSSARY.md
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   └── schemas/
└── context/           🎓 Background
    └── COMPARISON_TO_TIME_2025.md
```

**Quick paths**:
- 🆕 **New user**: `docs/0-start/GETTING_STARTED.md` (30 min)
- 🔨 **Builder**: `docs/1-build/IMPLEMENTATION_GUIDE.md` (8 phases)
- 👨‍💻 **Developer**: `docs/2-use/WORKFLOW.md` (daily reference)
- 🔧 **Extender**: `docs/3-extend/EXTENSION_GUIDE.md` (add features)

## Acceptance Criteria

Before considering v1.0 complete:

- [ ] `nix develop` provides Rust, Python, jq, just
- [ ] `nix build .#rust_extractor` succeeds
- [ ] `just day` creates daily tree
- [ ] `just ai spec=...` writes artifacts with run manifest
- [ ] `just mine repo=X name=Y limit=5` creates commit folders
- [ ] `just summ sha=abc123` creates analysis_summary.md
- [ ] `nix flake check` passes in CI
- [ ] Pre-commit hooks run on commit
- [ ] Secrets are excluded from git
- [ ] All scripts pass shellcheck

## Contributing

See [DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md) for:
- Code style guidelines
- Testing requirements
- Commit message format
- PR process

## License

[Choose appropriate license]

---

**Status**: 🚧 In Development  
**Inspiration**: [time-2025 repository](https://github.com/meta-introspector/time-2025)

