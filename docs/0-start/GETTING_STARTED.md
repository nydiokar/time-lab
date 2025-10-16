# Getting Started with Time-Lab

Complete guide from installation to your first experiment. **Time**: 30 minutes.

---

## Prerequisites

- **Nix** with flakes enabled
- **Git** for version control
- **5GB disk space** for Nix store
- **OS**: Linux, macOS, or WSL2 on Windows

### Install Nix

```bash
# Single-user installation
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Install Direnv (Optional)

```bash
nix profile install nixpkgs#direnv
# Add to shell: eval "$(direnv hook bash)"
```

---

## Quick Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/time-lab.git
cd time-lab
```

### 2. Enter Development Environment

```bash
nix develop
# Or with direnv: direnv allow
```

### 3. Create Today's Workspace

```bash
just day
```

This creates:
```
2025/10/15/
├── README.md
├── ai-team/specs/ artifacts/
├── analyzer/inputs/ outputs/
└── knowledge/notes.md graph/
```

---

## Your First Experiment

Let's create an LLM task that generates a tutorial about Nix.

### Step 1: Create Spec (5 min)

```bash
cat > latest/ai-team/specs/nix_tutorial.json << 'EOF'
{
  "kind": "llm",
  "version": "1.0",
  "name": "Nix Tutorial",
  "inputs": {
    "prompt": "Write a beginner tutorial about Nix. Include: what it is, key concepts, and 3 examples."
  },
  "config": {
    "model": "ollama:qwen2.5:7b",
    "temperature": 0.7,
    "seed": 42,
    "max_tokens": 1000
  }
}
EOF
```

### Step 2: Validate Spec (1 min)

```bash
# Check JSON is valid
jq empty latest/ai-team/specs/nix_tutorial.json && echo "✅ Valid"

# Optional: Schema validation
npm install -g ajv-cli
ajv validate -s docs/schemas/llm_task.schema.json -d latest/ai-team/specs/nix_tutorial.json
```

### Step 3: Run Task (2 min)

```bash
just ai spec=latest/ai-team/specs/nix_tutorial.json

# Output:
# 🚀 Starting LLM task
#    Run ID: a3f5b2c1...
#    Manifest: latest/ai-team/artifacts/run_a3f5b2c1.json
# ✅ Task completed
```

### Step 4: Examine Manifest (2 min)

```bash
cat latest/ai-team/artifacts/run_*.json | jq .
```

Key fields:
- `run_id` - Unique hash
- `git_sha` - Code version
- `task.spec_hash` - Input hash
- `status` - ok/error
- `artifacts` - Output files

**Why this matters**: Given the same spec + git SHA + flake.lock, you can reproduce this run.

### Step 5: Review Output (5 min)

```bash
# View artifacts
ls latest/ai-team/artifacts/

# Read output
cat latest/ai-team/artifacts/output.md
```

### Step 6: Document (3 min)

```bash
cat >> latest/knowledge/notes.md << 'EOF'
## Nix Tutorial Generation

**Run**: a3f5b2c1
**Model**: Qwen2.5 7B
**Temperature**: 0.7

### Results
- Generated clear, beginner-friendly content
- Temperature 0.7 good for creative tasks
- Seed 42 enables reproduction

### Next
- Try temp 0.3 for more deterministic output
- Test with different models
EOF
```

---

## Common Commands

```bash
just                # List all commands
just day            # Create today's workspace
just ai spec=FILE   # Run LLM task
just check          # Run all checks
just clean          # Clean build artifacts
```

---

## Key Concepts

### Spec
JSON file describing **what** to do. Located in `specs/`.

```json
{
  "kind": "llm",
  "inputs": { "prompt": "..." },
  "config": { "temperature": 0.7 }
}
```

### Run
Single execution. Creates **manifest** + **artifacts**.

### Manifest
`run.json` documenting **provenance**:
- What ran (spec hash)
- When (timestamps)
- Where (git SHA, flake.lock hash)
- Result (status, artifacts)

### Artifacts
Output files produced by run.

### Workspace
Date folder (`YYYY/MM/DD/`) containing all work for that day.

---

## Next Experiments

### Different Temperature

```bash
cp latest/ai-team/specs/nix_tutorial.json \
   latest/ai-team/specs/nix_tutorial_temp03.json

jq '.config.temperature = 0.3' \
   latest/ai-team/specs/nix_tutorial_temp03.json > temp && mv temp latest/ai-team/specs/nix_tutorial_temp03.json

just ai spec=latest/ai-team/specs/nix_tutorial_temp03.json
```

### Git Mining

```bash
cat > latest/analyzer/inputs/mine_react.json << 'EOF'
{
  "kind": "mining",
  "version": "1.0",
  "inputs": {
    "repository": {"owner": "facebook", "name": "react"}
  },
  "config": {"limit": 5}
}
EOF

just mine repo=facebook name=react limit=5
```

### Multi-Day Work

```bash
# Tomorrow
just day  # Creates 2025/10/16

# Continue experiment
cp latest/ai-team/specs/nix_tutorial.json 2025/10/16/ai-team/specs/nix_v2.json
```

---

## Troubleshooting

### "experimental feature disabled"
```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### "just: command not found"
```bash
nix develop  # Enters dev environment
```

### Can't find artifacts
```bash
cd latest/ai-team/artifacts  # Use latest/ symlink
```

---

## What You Learned

✅ Create workspace with `just day`
✅ Write specs following schema
✅ Run tasks via `just` commands
✅ Examine manifests for provenance
✅ Analyze artifacts
✅ Document findings

### The Loop

```
Spec → Validation → Run → Manifest → Artifacts → Analysis → Knowledge
```

---

## Next Steps

**Building**: See `docs/1-build/IMPLEMENTATION_GUIDE.md`
**Daily use**: See `docs/2-use/WORKFLOW.md`
**Extending**: See `docs/3-extend/EXTENSION_GUIDE.md`
**Reference**: See `docs/reference/`

---

**Time to complete**: 30 minutes
**You're ready to experiment!** 🚀
