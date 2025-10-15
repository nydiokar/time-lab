# Build Guide

Primary reference for building Time-Lab.

---

## Primary Source

**Main Guide**: `docs/1-build/IMPLEMENTATION_GUIDE.md`

This is the canonical build guide. Follow it **exactly**, phase by phase.

---

## Build Phases

### Phase 0: Prerequisites (15 min)
- Install Nix with flakes
- Install direnv (optional)
- Verify environment

### Phase 1: Foundation (30 min)
- Create `flake.nix`
- Create `.gitignore`, `.gitattributes`
- Create `Justfile`
- Create `.envrc`
- Test: `nix develop` works

### Phase 2: Core Scripts (45 min)
- `scripts/today.sh` - Create date folders
- `scripts/run_llm_task.sh` - Execute LLM tasks
- `scripts/mine_commits.sh` - Git mining (placeholder)
- `scripts/summarize_diff.sh` - Diff analysis (placeholder)
- `scripts/sync_latest.sh` - Update symlinks
- Test: `just day` works

### Phase 3: Rust Tools (1 hour)
- Create `tools/rust_extractor/`
- Add to `flake.nix` as package
- Build with `nix build .#rust_extractor`
- Test: Binary runs

### Phase 4: Python Tools (1 hour)
- Create `tools/py_post/`
- Add Python devShell to `flake.nix`
- Set up venv
- Test: Tool runs

### Phase 5: Quality & Safety (45 min)
- Add `.pre-commit-config.yaml`
- Add shellcheck to checks
- Create `.secrets.baseline`
- Test: `just check` works

### Phase 6: Documentation & Schemas (30 min)
- Schemas already exist in `docs/reference/schemas/`
- Verify they're accessible
- Test validation

### Phase 7: CI/CD (30 min)
- Create `.github/workflows/ci.yml`
- Test locally with `nix flake check`

### Phase 8: Validation (30 min)
- Create `tests/integration/test_workflow.sh`
- Run all acceptance tests
- Verify checklist in README.md

**Total Time**: ~6-8 hours

---

## Reference Material

### When Stuck on Terms
`docs/reference/GLOSSARY.md` - Canonical definitions

**Key terms**:
- Manifest = `run.json` (provenance record)
- Spec = Input JSON describing task
- Artifact = Output file from a run
- Run = Single execution
- Workspace = `YYYY/MM/DD/` folder

### When Stuck on Architecture
`docs/reference/ARCHITECTURE.md` - System design

**Key concepts**:
- Reproducibility via Nix + git SHA + flake.lock
- Date-based organization
- DevShell profiles
- Manifest-driven provenance

### When Stuck on Decisions
`docs/reference/DECISIONS.md` - Why we made certain choices

**Key decisions**:
- D003: Why YYYY/MM/DD structure
- D006: Why devShells not full nixification
- D009: Why strict shell mode

### Schemas
`docs/reference/schemas/` - JSON validation

- `run.schema.json` - Validates manifests
- `spec.schema.json` - Validates base specs
- `llm_task.schema.json` - Validates LLM specs
- `mining_task.schema.json` - Validates mining specs

---

## What to Ignore During Build

**Don't read these until after Phase 8**:

- `docs/0-start/` - Post-build tutorials
- `docs/2-use/` - Daily workflow (for after build)
- `docs/3-extend/` - Extensions (for after build)
- `docs/context/` - Background info (optional reading)

**Focus on**:
- `docs/1-build/IMPLEMENTATION_GUIDE.md` (primary)
- `docs/reference/` (when stuck)

---

## Validation Checklist

After Phase 8, verify:

- [ ] `nix develop` provides Rust, Python, jq, just
- [ ] `nix build .#rust_extractor` succeeds
- [ ] `just day` creates date tree
- [ ] `just ai spec=...` writes artifacts
- [ ] `just mine repo=X name=Y limit=5` works
- [ ] `just summ sha=abc123` works
- [ ] `nix flake check` passes
- [ ] Pre-commit hooks run on commit
- [ ] Secrets excluded from git
- [ ] All scripts pass shellcheck

---

## Common Patterns

### Creating a Script
```bash
cat > scripts/my_script.sh << 'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Script content
EOF

chmod +x scripts/my_script.sh
```

### Adding to Justfile
```makefile
my-command arg:
    @bash scripts/my_script.sh "{{arg}}"
```

### Testing
```bash
# Test the command
just my-command test-value

# Verify output
ls expected/output/path
```

---

## Success Criteria

**Phase complete when**:
1. All tasks in that phase are done
2. Tests for that phase pass
3. You can demonstrate the new functionality
4. `.ai/CONTEXT.md` updated with checkmarks

**Build complete when**:
1. All 8 phases marked complete in `.ai/CONTEXT.md`
2. Validation checklist passes
3. You can run a complete workflow end-to-end

---

## Quick Reference Commands

```bash
# Enter dev environment
nix develop

# Create today's workspace
just day

# Run LLM task
just ai spec=path/to/spec.json

# Build Rust tool
nix build .#rust_extractor

# Run all checks
just check

# Update dependencies
nix flake update
```

---

**Remember**: Follow IMPLEMENTATION_GUIDE.md exactly. Don't improvise. Validate each step.

