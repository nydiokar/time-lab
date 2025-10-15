# Daily Workflow

How to work with Time-Lab day-to-day.

---

## Daily Routine

### Starting Your Day

```bash
cd time-lab
nix develop
just day
```

### Working on Features

```bash
git checkout -b feature/my-feature
# Edit files
just check  # Run tests/lint
git commit -m "feat: add feature"
git push
```

### Running Experiments

```bash
# Create spec
cat > latest/ai-team/specs/experiment.json << 'EOF'
{"kind": "llm", "version": "1.0", ...}
EOF

# Run
just ai spec=latest/ai-team/specs/experiment.json

# Review
cat latest/ai-team/artifacts/run_*.json | jq .
```

### Ending Your Day

```bash
# Document
echo "## Today's findings" >> latest/knowledge/notes.md

# Commit
git add YYYY/MM/DD/
git commit -m "experiment: description"
git push
```

---

## Coding Standards

### General Principles

1. **Functional > OOP** - Prefer pure functions
2. **Strict types** - Use type annotations
3. **DRY** - Don't repeat yourself
4. **KISS** - Keep it simple
5. **YAGNI** - Don't implement until needed

### By Language

#### Nix
```nix
# Format with alejandra
nix develop --command alejandra .
```

#### Shell
```bash
#!/usr/bin/env bash
set -Eeuo pipefail  # REQUIRED
IFS=$'\n\t'

# Exit codes: 0=success, 64=usage, 65=data, 70=internal
```

#### Rust
```bash
cargo fmt
cargo clippy -- -D warnings
```

#### Python
```python
# Use Pydantic models, strict types, no @staticmethod
from pydantic import BaseModel

def process(input: Path) -> list[str]:
    ...
```

---

## Testing

```bash
just check                    # All checks
nix develop --command pytest  # Python tests
cargo test                    # Rust tests
```

---

## Version Control

### Commit Messages

```
<type>(<scope>): <subject>

<body>
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```bash
git commit -m "feat(llm): add temperature parameter

- Update spec schema
- Log in manifest
- Default to 0.7"
```

### Branch Strategy

- `main` - Stable
- `feature/*` - New features
- `fix/*` - Bug fixes
- `experiment/*` - Research (may not merge)

---

## Common Tasks

### Update Dependencies

```bash
nix flake update
git diff flake.lock
git commit -m "chore: update dependencies"
```

### Add Python Package

```bash
# Edit pyproject.toml
nix develop .#python_ml
pip install -e ".[dev]"
```

### Add Rust Dependency

```bash
cd tools/rust_extractor
cargo add serde_json
cargo build
```

---

## Troubleshooting

**Nix build fails**: `nix build .#rust_extractor --rebuild`  
**Pre-commit fails**: `black . && ruff check --fix .`  
**Python imports fail**: `source .venv/bin/activate`  
**Disk space low**: `nix-collect-garbage --delete-older-than 7d`

---

See `docs/reference/` for detailed references.

