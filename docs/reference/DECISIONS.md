# Architectural Decision Records (ADR)

This document tracks important architectural decisions made during the development of Time-Lab.

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

**Context**: Development on Windows requires Linux tooling for Nix, but Docker adds overhead and complexity.

**Decision**: Run in WSL2/VM rather than Docker containers.

**Consequences**:
- ✅ Full Nix support with native performance
- ✅ Better file system performance
- ✅ Can use all system resources
- ❌ Requires WSL2 setup and configuration
- ❌ More resource overhead than native Linux
- ❌ Windows users need additional setup steps

---

## D002: Single Monorepo

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need to manage multiple tools (Rust, Python, scripts) for AI experiments with consistent versioning.

**Decision**: Use single monorepo with one `flake.lock` for all dependencies.

**Consequences**:
- ✅ One source of truth for versions
- ✅ Simplified cross-tool integration
- ✅ Easier to maintain and review changes
- ✅ Atomic updates across all tools
- ❌ Larger checkout size
- ❌ All tools share same dependency versions (less flexibility)
- ❌ Longer CI build times

**Alternatives Considered**:
- Multiple repos with separate locks → Rejected due to version drift
- Git submodules → Rejected due to complexity

---

## D003: Date Tree YYYY/MM/DD

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need intuitive organization for daily experimental work that matches how researchers think about their work.

**Decision**: Use `YYYY/MM/DD` folder structure for all artifacts.

**Consequences**:
- ✅ Natural chronological navigation
- ✅ Easy to find "what did I do on date X"
- ✅ Works well with file explorers
- ✅ Mirrors how time-2025 repo is organized
- ✅ Can easily archive old months/years
- ❌ Deeper nesting than flat structure
- ❌ Requires tooling to create folders
- ❌ May be confusing for single-task projects

**Alternatives Considered**:
- Flat with date prefix (`20251015_experiment`) → Rejected, too many files in one dir
- UUID-based → Rejected, not human-friendly
- Task-based (`experiments/quantum/`) → Rejected, doesn't capture temporal flow

---

## D004: Run Manifests Must Follow Schema

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need reproducibility and traceability of all executions with machine-readable format.

**Decision**: Every run must produce `run.json` following `run.schema.json`.

**Consequences**:
- ✅ Structured provenance tracking
- ✅ Machine-readable execution history
- ✅ Can validate and query manifests
- ✅ Enables future tooling (web UI, analysis)
- ✅ Explicit rather than implicit metadata
- ❌ Additional complexity in scripts
- ❌ Must maintain schema as requirements evolve
- ❌ Overhead for simple one-off runs

**Alternatives Considered**:
- Freeform logs → Rejected, not queryable
- Database storage → Rejected, adds infrastructure dependency
- YAML format → Rejected, JSON is more universal

---

## D005: Model Calls Logged with Params + Seed

**Date**: 2025-10-15
**Status**: Accepted

**Context**: LLM outputs are non-deterministic without parameter tracking, making experiments hard to reproduce.

**Decision**: Log `temperature`, `top_p`, `seed`, `max_tokens`, model hash for all LLM calls.

**Consequences**:
- ✅ Reproducible LLM experiments (when seed is supported)
- ✅ Can debug unexpected outputs
- ✅ Can compare runs with different parameters
- ✅ Documents exact conditions for future reference
- ❌ Requires instrumentation of all LLM calls
- ❌ Not all models support all parameters (especially seed)
- ❌ API models may silently update despite logging

**Best Practices**:
- Use local models (Ollama, LlamaCpp) when reproducibility is critical
- Document when parameters are not supported
- Log API version/endpoint for cloud models

---

## D006: Existing Projects Wrapped via DevShells

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Want to integrate existing Rust/Python projects without requiring immediate full nixification.

**Decision**: Use Nix devShells to provide environments; don't require pure Nix builds initially.

**Consequences**:
- ✅ Lower barrier to adoption
- ✅ Can gradually nixify projects
- ✅ Familiar workflows (cargo, pip) still work
- ✅ Teams can start using Time-Lab immediately
- ❌ Less hermetic than pure Nix builds
- ❌ May have impurities (network, system deps)
- ❌ Reproducibility not guaranteed until fully nixified

**Migration Path**:
1. Start with devShell only
2. Add `buildInputs` for system dependencies
3. Create `buildRustPackage` / `buildPythonPackage`
4. Add to CI builds
5. Fully reproducible!

---

## D007: UTC Timestamps Everywhere

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Timezone ambiguity makes it hard to correlate events and reproduces.

**Decision**: All timestamps in manifests and logs use UTC (ISO 8601 format).

**Consequences**:
- ✅ No timezone ambiguity
- ✅ Easy to compare across systems
- ✅ Standard format for APIs
- ✅ Works globally (distributed teams)
- ❌ Less intuitive for local time reading
- ❌ Requires conversion for user display

**Format**: `YYYY-MM-DDTHH:MM:SSZ` (e.g., `2025-10-15T14:30:00Z`)

**Optional**: Can include local time as additional field, but UTC is canonical.

---

## D008: Secrets Outside Git (SOPS or .env)

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need to manage API keys and credentials without committing them to git.

**Decision**: Use `.env` files for local development (gitignored) and `sops-nix` for production secrets.

**Consequences**:
- ✅ Secrets never in git history
- ✅ Pre-commit hooks catch accidental leaks
- ✅ `sops-nix` provides encryption at rest
- ✅ Team can share secrets securely (via sops)
- ❌ New developers need manual secret setup
- ❌ Two different systems (dev vs prod)
- ❌ Must document what secrets are needed

**Alternatives Considered**:
- Environment variables only → Rejected, not persistent
- HashiCorp Vault → Rejected, too complex for small teams
- Git-crypt → Rejected, `sops-nix` is more Nix-native

---

## D009: Shell Scripts with Strict Mode

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Bash scripts can silently fail or produce unexpected results without proper error handling.

**Decision**: All shell scripts must use `set -Eeuo pipefail` and `IFS=$'\n\t'`.

**Consequences**:
- ✅ Scripts fail fast on errors
- ✅ Easier to debug
- ✅ Prevents silent failures
- ✅ Industry best practice
- ❌ Requires more careful programming
- ❌ Some scripts may need error handling refactoring
- ❌ Less forgiving for quick prototypes

**Template**:
```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
```

---

## D010: Network Offline by Default

**Date**: 2025-10-15
**Status**: Proposed

**Context**: Uncontrolled network access makes builds non-reproducible and potentially insecure.

**Decision**: Nix builds run with `--offline` by default; explicit `allow_net: true` required for network access.

**Consequences**:
- ✅ More reproducible builds
- ✅ Explicit about network dependencies
- ✅ Prevents accidental network calls
- ❌ Requires pre-fetching for network resources
- ❌ May be confusing initially
- ❌ Needs good error messages when network is needed

**Status**: Proposed (not yet implemented)

---

## D011: Pre-commit Hooks for Quality

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Want to catch formatting, linting, and security issues before they enter git history.

**Decision**: Use `pre-commit` framework with hooks for formatting, linting, and secret detection.

**Consequences**:
- ✅ Consistent code formatting
- ✅ Catch issues early
- ✅ Prevent secret leaks
- ✅ Reduce review burden
- ❌ Slower commits (hooks take time)
- ❌ Learning curve for new contributors
- ❌ Can be bypassed with `--no-verify` (trust-based)

**Hooks Enabled**:
- `black`, `ruff` (Python)
- `shellcheck`, `shfmt` (Shell)
- `alejandra` (Nix)
- `detect-secrets` (Security)
- Basic checks (trailing whitespace, large files, etc.)

---

## D012: Justfile for Task Running

**Date**: 2025-10-15
**Status**: Accepted

**Context**: Need simple, readable way to run common tasks without remembering complex commands.

**Decision**: Use `just` (command runner) instead of Make.

**Consequences**:
- ✅ Cleaner syntax than Make
- ✅ No .PHONY declarations needed
- ✅ Better error messages
- ✅ No tab vs space issues
- ❌ Less ubiquitous than Make
- ❌ Another tool to learn
- ❌ May confuse users expecting Makefile

**Alternatives Considered**:
- Makefile → Rejected due to syntax quirks
- Custom scripts → Rejected, less discoverable
- npm scripts → Rejected, not language-agnostic

---

## Template for New Decisions

```markdown
## D0XX: Short Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded

**Context**:
What is the situation and problem? What forces are at play?

**Decision**:
What did we decide to do? Be specific and actionable.

**Consequences**:
- ✅ Positive consequence 1
- ✅ Positive consequence 2
- ❌ Negative consequence 1
- ❌ Negative consequence 2

**Alternatives Considered** (optional):
- Option A → Rejected because...
- Option B → Rejected because...

**Related Decisions** (optional):
- Supersedes: D00X
- Related to: D00Y
```

---

## Decision Status Definitions

- **Proposed**: Under discussion, not yet implemented
- **Accepted**: Agreed upon and currently in effect
- **Deprecated**: No longer recommended but may still exist in codebase
- **Superseded**: Replaced by a newer decision

---

## Decision Review Process

1. **Propose**: Open a PR with new decision in this file
2. **Discuss**: Team reviews consequences and alternatives
3. **Accept**: Merge PR, status becomes "Accepted"
4. **Implement**: Actually build according to decision
5. **Review**: Periodically revisit (quarterly?) to see if still valid

---

**Last Updated**: 2025-10-15
**Next Review**: 2026-01-15
