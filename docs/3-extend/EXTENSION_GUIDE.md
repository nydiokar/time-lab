# Extension Guide

How to extend Time-Lab with new tools, task types, and integrations.

## Table of Contents

- [Extension Points](#extension-points)
- [Adding a New Task Type](#adding-a-new-task-type)
- [Adding a New Tool](#adding-a-new-tool)
- [Adding a DevShell Profile](#adding-a-devshell-profile)
- [Adding External Integrations](#adding-external-integrations)
- [Plugin System (Future)](#plugin-system-future)

---

## Extension Points

Time-Lab is designed to be extended at these points:

| Extension Point | What You Add | Where | Complexity |
|-----------------|--------------|-------|------------|
| **Task Type** | New kind of work (e.g., "compile", "test") | Schema + script | Medium |
| **Tool** | Binary/library for processing | `tools/` + `flake.nix` | Low-Medium |
| **DevShell** | Development environment profile | `flake.nix` | Low |
| **Integration** | External service connection | `scripts/` + config | Medium |
| **Validation** | Custom checks for specs/outputs | Schema + script | Low |

---

## Adding a New Task Type

**Example**: Add a "compile" task type for building code with detailed metrics.

### Step 1: Define the Schema

Create `docs/schemas/compile_task.schema.json`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://time-lab.dev/schemas/compile_task.schema.json",
  "title": "Compile Task Specification",
  "description": "Schema for compilation tasks with metrics",
  "allOf": [
    {
      "$ref": "spec.schema.json"
    },
    {
      "type": "object",
      "properties": {
        "kind": {
          "const": "compile"
        },
        "inputs": {
          "type": "object",
          "required": ["source_dir", "language"],
          "properties": {
            "source_dir": {
              "type": "string",
              "description": "Directory containing source code",
              "examples": ["src/"]
            },
            "language": {
              "type": "string",
              "enum": ["rust", "python", "typescript"],
              "description": "Programming language"
            },
            "entry_point": {
              "type": "string",
              "description": "Main file (if applicable)",
              "examples": ["main.rs", "app.py"]
            }
          }
        },
        "config": {
          "type": "object",
          "properties": {
            "optimization_level": {
              "type": "string",
              "enum": ["none", "debug", "release"],
              "default": "debug"
            },
            "parallel_jobs": {
              "type": "integer",
              "minimum": 1,
              "default": 4
            },
            "flags": {
              "type": "array",
              "items": {"type": "string"},
              "description": "Additional compiler flags"
            }
          }
        }
      }
    }
  ],
  "examples": [
    {
      "kind": "compile",
      "version": "1.0",
      "name": "Compile Rust Project",
      "inputs": {
        "source_dir": "tools/rust_extractor",
        "language": "rust",
        "entry_point": "src/main.rs"
      },
      "config": {
        "optimization_level": "release",
        "parallel_jobs": 8,
        "flags": ["--target", "x86_64-unknown-linux-gnu"]
      }
    }
  ]
}
```

### Step 2: Create the Execution Script

Create `scripts/run_compile_task.sh`:

```bash
#!/usr/bin/env bash
# Run a compilation task
# Usage: ./run_compile_task.sh <spec.json>

set -Eeuo pipefail
IFS=$'\n\t'

SPEC_FILE="$1"

# Validate spec exists and is valid JSON
if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: Spec file not found: $SPEC_FILE" >&2
  exit 65
fi

if ! jq empty "$SPEC_FILE" 2>/dev/null; then
  echo "Error: Invalid JSON in spec file" >&2
  exit 65
fi

# Extract spec fields
SOURCE_DIR=$(jq -r '.inputs.source_dir' "$SPEC_FILE")
LANGUAGE=$(jq -r '.inputs.language' "$SPEC_FILE")
OPT_LEVEL=$(jq -r '.config.optimization_level // "debug"' "$SPEC_FILE")
PARALLEL_JOBS=$(jq -r '.config.parallel_jobs // 4' "$SPEC_FILE")

# Generate run metadata
GIT_SHA=$(git rev-parse HEAD)
FLAKE_LOCK_SHA=$(sha256sum flake.lock | cut -d' ' -f1)
TIMESTAMP_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SPEC_HASH=$(sha256sum "$SPEC_FILE" | cut -d' ' -f1)
RUN_ID=$(echo -n "${SPEC_HASH}${GIT_SHA}${FLAKE_LOCK_SHA}${TIMESTAMP_START}" | sha256sum | cut -d' ' -f1)

# Determine output directory
SPEC_DIR=$(dirname "$SPEC_FILE")
ARTIFACTS_DIR="${SPEC_DIR}/../artifacts"
mkdir -p "$ARTIFACTS_DIR"

# Create run manifest
RUN_MANIFEST="$ARTIFACTS_DIR/run_${RUN_ID:0:8}.json"

cat > "$RUN_MANIFEST" << EOF
{
  "run_id": "$RUN_ID",
  "timestamp_start": "$TIMESTAMP_START",
  "timestamp_end": null,
  "cmd": "$0 $*",
  "git_sha": "$GIT_SHA",
  "flake_lock_sha256": "$FLAKE_LOCK_SHA",
  "task": {
    "kind": "compile",
    "spec_path": "$SPEC_FILE",
    "spec_hash": "$SPEC_HASH"
  },
  "status": "running",
  "artifacts": []
}
EOF

echo "🔨 Starting compilation task"
echo "   Run ID: ${RUN_ID:0:8}"
echo "   Language: $LANGUAGE"
echo "   Source: $SOURCE_DIR"

# Execute compilation based on language
BUILD_LOG="$ARTIFACTS_DIR/build_${RUN_ID:0:8}.log"
METRICS_FILE="$ARTIFACTS_DIR/metrics_${RUN_ID:0:8}.json"

case "$LANGUAGE" in
  rust)
    cd "$SOURCE_DIR"

    # Start timing
    START_TIME=$(date +%s)

    # Compile
    if [ "$OPT_LEVEL" = "release" ]; then
      cargo build --release -j "$PARALLEL_JOBS" 2>&1 | tee "$BUILD_LOG"
    else
      cargo build -j "$PARALLEL_JOBS" 2>&1 | tee "$BUILD_LOG"
    fi

    # End timing
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    # Collect metrics
    cat > "$METRICS_FILE" << METRICS_EOF
{
  "duration_seconds": $DURATION,
  "language": "rust",
  "optimization": "$OPT_LEVEL",
  "binary_size_bytes": $(stat -c%s target/${OPT_LEVEL}/$(jq -r '.package.name' Cargo.toml) 2>/dev/null || echo 0),
  "warnings": $(grep -c "warning:" "$BUILD_LOG" || echo 0),
  "errors": $(grep -c "error:" "$BUILD_LOG" || echo 0)
}
METRICS_EOF
    ;;

  python)
    # Python compilation (bytecode)
    python3 -m py_compile "$SOURCE_DIR"/*.py 2>&1 | tee "$BUILD_LOG"
    ;;

  *)
    echo "Error: Unsupported language: $LANGUAGE" >&2
    exit 65
    ;;
esac

# Update manifest
TIMESTAMP_END=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq --arg ts "$TIMESTAMP_END" \
   --arg status "ok" \
   --slurpfile metrics "$METRICS_FILE" \
   '.timestamp_end = $ts |
    .status = $status |
    .metrics = $metrics[0] |
    .artifacts = ["build_'"${RUN_ID:0:8}"'.log", "metrics_'"${RUN_ID:0:8}"'.json"]' \
   "$RUN_MANIFEST" > "${RUN_MANIFEST}.tmp" && \
   mv "${RUN_MANIFEST}.tmp" "$RUN_MANIFEST"

echo "✅ Compilation completed"
echo "   Manifest: $RUN_MANIFEST"
echo "   Metrics: $METRICS_FILE"
```

Make it executable:

```bash
chmod +x scripts/run_compile_task.sh
```

### Step 3: Add to Justfile

Add command to `Justfile`:

```makefile
# Compile code with metrics
compile spec:
    @echo "Compiling: {{spec}}"
    @bash scripts/run_compile_task.sh "{{spec}}"
```

### Step 4: Test the New Task Type

```bash
# Create test spec
cat > latest/analyzer/inputs/compile_test.json << 'EOF'
{
  "kind": "compile",
  "version": "1.0",
  "name": "Build rust_extractor",
  "inputs": {
    "source_dir": "tools/rust_extractor",
    "language": "rust"
  },
  "config": {
    "optimization_level": "release",
    "parallel_jobs": 4
  }
}
EOF

# Run it
just compile spec=latest/analyzer/inputs/compile_test.json

# Check results
cat latest/analyzer/artifacts/metrics_*.json
```

### Step 5: Document

Update `docs/GLOSSARY.md`:

```markdown
### Compile Task
**Definition**: A task that compiles source code and collects build metrics.

**Spec Kind**: `compile`

**Outputs**: Build log, metrics (duration, binary size, warnings/errors)
```

---

## Adding a New Tool

**Example**: Add a Python tool for analyzing CSV files.

### Step 1: Create Tool Structure

```bash
mkdir -p tools/csv_analyzer
cd tools/csv_analyzer
```

### Step 2: Write the Tool

Create `tools/csv_analyzer/pyproject.toml`:

```toml
[build-system]
requires = ["setuptools>=65.0"]
build-backend = "setuptools.build_meta"

[project]
name = "csv-analyzer"
version = "0.1.0"
description = "CSV analysis tool for Time-Lab"
requires-python = ">=3.11"
dependencies = [
    "pandas>=2.0",
    "click>=8.0",
    "pydantic>=2.0",
]

[project.scripts]
csv-analyzer = "csv_analyzer.main:cli"
```

Create `tools/csv_analyzer/csv_analyzer/main.py`:

```python
#!/usr/bin/env python3
"""CSV analysis tool."""

from pathlib import Path
import json
import click
import pandas as pd
from pydantic import BaseModel


class AnalysisResult(BaseModel):
    """Analysis results."""
    rows: int
    columns: int
    column_names: list[str]
    numeric_columns: list[str]
    summary_stats: dict[str, dict[str, float]]


@click.command()
@click.option('--input', '-i', type=click.Path(exists=True), required=True)
@click.option('--output', '-o', type=click.Path(), required=True)
def cli(input: str, output: str) -> None:
    """Analyze CSV file and output summary statistics."""
    click.echo(f"📊 CSV Analyzer")
    click.echo(f"   Input: {input}")

    # Read CSV
    df: pd.DataFrame = pd.read_csv(input)

    # Analyze
    numeric_cols: list[str] = df.select_dtypes(include=['number']).columns.tolist()

    summary_stats: dict[str, dict[str, float]] = {}
    for col in numeric_cols:
        summary_stats[col] = {
            "mean": float(df[col].mean()),
            "std": float(df[col].std()),
            "min": float(df[col].min()),
            "max": float(df[col].max()),
        }

    # Create result
    result: AnalysisResult = AnalysisResult(
        rows=len(df),
        columns=len(df.columns),
        column_names=df.columns.tolist(),
        numeric_columns=numeric_cols,
        summary_stats=summary_stats,
    )

    # Write output
    with open(output, 'w') as f:
        f.write(result.model_dump_json(indent=2))

    click.echo(f"✅ Analyzed {result.rows} rows, {result.columns} columns")
    click.echo(f"   Output: {output}")


if __name__ == '__main__':
    cli()
```

### Step 3: Add to Flake

Update `flake.nix`:

```nix
packages = {
  # ... existing packages ...

  csv_analyzer = pkgs.python311Packages.buildPythonPackage {
    pname = "csv-analyzer";
    version = "0.1.0";
    src = ./tools/csv_analyzer;

    propagatedBuildInputs = with pkgs.python311Packages; [
      pandas
      click
      pydantic
    ];

    format = "pyproject";
  };
};
```

### Step 4: Build and Test

```bash
# Build
nix build .#csv_analyzer

# Test
echo "name,age,score
Alice,25,95
Bob,30,87
Carol,28,92" > test.csv

./result/bin/csv-analyzer --input test.csv --output analysis.json
cat analysis.json
```

### Step 5: Integrate with Workflow

```bash
# Add to Justfile
analyze-csv input output:
    nix run .#csv_analyzer -- --input {{input}} --output {{output}}
```

---

## Adding a DevShell Profile

**Example**: Add a profile for data science work.

### Update flake.nix

```nix
devShells = {
  # ... existing shells ...

  data_science = pkgs.mkShell {
    name = "time-lab-data-science";
    buildInputs = with pkgs; [
      # Python with data science packages
      python311
      python311Packages.pandas
      python311Packages.numpy
      python311Packages.matplotlib
      python311Packages.jupyter
      python311Packages.scikit-learn

      # R (optional)
      R
      rPackages.tidyverse

      # Tools
      jq
      just
      git
    ];

    shellHook = ''
      echo "📊 Data Science Environment"
      echo "   Python: $(python --version)"
      echo "   Packages: pandas, numpy, matplotlib, jupyter, scikit-learn"

      # Create venv if needed
      if [ ! -d .venv-ds ]; then
        python -m venv .venv-ds
        source .venv-ds/bin/activate
        pip install ipykernel
      else
        source .venv-ds/bin/activate
      fi
    '';
  };
};
```

### Use the Profile

```bash
# Enter data science shell
nix develop .#data_science

# Or create .envrc for auto-activation
echo "use flake .#data_science" > 2025/10/15/analyzer/.envrc
cd 2025/10/15/analyzer
direnv allow
# Now automatically in data science environment!
```

---

## Adding External Integrations

**Example**: Integrate with GitHub API for commit mining.

### Step 1: Define Configuration

Create `configs/github.template.json`:

```json
{
  "api_url": "https://api.github.com",
  "token": "YOUR_GITHUB_TOKEN_HERE",
  "rate_limit": {
    "requests_per_hour": 5000
  },
  "cache": {
    "enabled": true,
    "ttl_seconds": 3600
  }
}
```

### Step 2: Create Integration Script

Create `scripts/lib/github_api.sh`:

```bash
#!/usr/bin/env bash
# GitHub API helper functions

set -Eeuo pipefail
IFS=$'\n\t'

GITHUB_CONFIG="${GITHUB_CONFIG:-configs/github.json}"

github_api_call() {
  local endpoint="$1"
  local method="${2:-GET}"

  # Load config
  if [ ! -f "$GITHUB_CONFIG" ]; then
    echo "Error: GitHub config not found: $GITHUB_CONFIG" >&2
    return 1
  fi

  local api_url=$(jq -r '.api_url' "$GITHUB_CONFIG")
  local token=$(jq -r '.token' "$GITHUB_CONFIG")

  # Make request
  curl -X "$method" \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github.v3+json" \
    "${api_url}${endpoint}"
}

github_get_commits() {
  local owner="$1"
  local repo="$2"
  local limit="${3:-10}"

  github_api_call "/repos/${owner}/${repo}/commits?per_page=${limit}"
}

github_get_commit_diff() {
  local owner="$1"
  local repo="$2"
  local sha="$3"

  github_api_call "/repos/${owner}/${repo}/commits/${sha}" | \
    jq -r '.files[] | .patch' | \
    grep -v '^null$'
}
```

### Step 3: Use in Script

Update `scripts/mine_commits.sh`:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Source GitHub API helpers
source "$(dirname "$0")/lib/github_api.sh"

OWNER="$1"
REPO="$2"
LIMIT="${3:-10}"

echo "🔍 Mining commits from ${OWNER}/${REPO}"

# Get commits
COMMITS=$(github_get_commits "$OWNER" "$REPO" "$LIMIT")

# Process each commit
echo "$COMMITS" | jq -r '.[].sha' | while read sha; do
  echo "Processing commit: $sha"

  # Create output directory
  mkdir -p "latest/analyzer/outputs/commit_${sha}"

  # Get commit details
  github_api_call "/repos/${OWNER}/${REPO}/commits/${sha}" > \
    "latest/analyzer/outputs/commit_${sha}/metadata.json"

  # Extract message
  jq -r '.commit.message' \
    "latest/analyzer/outputs/commit_${sha}/metadata.json" > \
    "latest/analyzer/outputs/commit_${sha}/commit_message.txt"

  # Get diff
  github_get_commit_diff "$OWNER" "$REPO" "$sha" > \
    "latest/analyzer/outputs/commit_${sha}/full_diff.txt"
done

echo "✅ Mined $LIMIT commits"
```

### Step 4: Configure Secrets

```bash
# Copy template
cp configs/github.template.json secrets/github.json

# Edit with your token
# (Never commit secrets/github.json!)

# Set environment variable
export GITHUB_CONFIG=secrets/github.json
```

---

## Extension Contracts

### Task Execution Contract

All task execution scripts must follow this contract:

#### Inputs

1. **Spec file path** as first argument
2. **Spec must be valid JSON** conforming to schema

#### Outputs

1. **Run manifest** at `artifacts/run_<id>.json`
2. **Artifacts** listed in manifest
3. **Exit codes**:
   - `0`: Success
   - `64`: Usage error (bad arguments)
   - `65`: Data error (invalid spec)
   - `70`: Internal error

#### Manifest Requirements

Must include:
- `run_id` (SHA-256)
- `timestamp_start` (UTC)
- `timestamp_end` (UTC, can be null if running)
- `git_sha`
- `flake_lock_sha256`
- `task.kind`
- `status` (running/ok/error/cancelled)

#### Example Template

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# 1. Validate inputs
SPEC_FILE="$1"
[ -f "$SPEC_FILE" ] || exit 65
jq empty "$SPEC_FILE" || exit 65

# 2. Generate run metadata
RUN_ID=$(generate_run_id "$SPEC_FILE")
TIMESTAMP_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 3. Create manifest
cat > "artifacts/run_${RUN_ID:0:8}.json" << EOF
{
  "run_id": "$RUN_ID",
  "timestamp_start": "$TIMESTAMP_START",
  "status": "running",
  ...
}
EOF

# 4. Execute task
perform_task "$SPEC_FILE"

# 5. Update manifest
jq '.status = "ok" | .timestamp_end = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' \
  "artifacts/run_${RUN_ID:0:8}.json" > temp && \
  mv temp "artifacts/run_${RUN_ID:0:8}.json"

# 6. Exit with success
exit 0
```

---

## Tool Integration Contract

Tools must follow these conventions:

### CLI Interface

```bash
my-tool --input <file> --output <file> [OPTIONS]
```

### Options

- `--input, -i`: Input file (required)
- `--output, -o`: Output file (required)
- `--help`: Show help
- `--version`: Show version

### Output Format

- Primary output: JSON or structured text
- Logs: stderr
- Status: stdout

### Exit Codes

- `0`: Success
- `1`: General error
- `2`: Invalid arguments

### Example

```python
@click.command()
@click.option('--input', '-i', required=True)
@click.option('--output', '-o', required=True)
@click.version_option(version='1.0.0')
def main(input: str, output: str) -> None:
    """My tool description."""
    try:
        result = process(input)
        with open(output, 'w') as f:
            json.dump(result, f)
        click.echo(f"✅ Success: {output}")
    except Exception as e:
        click.echo(f"❌ Error: {e}", err=True)
        sys.exit(1)
```

---

## Plugin System (Future)

Future versions may support a plugin system:

### Plugin Structure

```
plugins/
└── my-plugin/
    ├── plugin.toml        # Plugin metadata
    ├── schema.json        # Task schema
    ├── run.sh             # Execution script
    └── README.md          # Documentation
```

### Plugin Metadata

```toml
[plugin]
name = "my-plugin"
version = "1.0.0"
description = "Does something cool"

[plugin.provides]
task_types = ["my-task"]
tools = ["my-tool"]

[plugin.requires]
nix_packages = ["jq", "curl"]
python_packages = ["requests"]
```

### Plugin Discovery

```bash
# List plugins
just plugins list

# Install plugin
just plugins install plugins/my-plugin

# Run plugin task
just run-task spec=my-task.json
```

This is not yet implemented but planned for v2.0.

---

## Best Practices for Extensions

### 1. Follow Conventions

- Use existing patterns (specs, manifests, artifacts)
- Follow naming conventions (snake_case for scripts, kebab-case for tools)
- Use standard exit codes

### 2. Document Everything

- Add JSON schema with examples
- Update GLOSSARY.md
- Add to Extension Guide

### 3. Test Thoroughly

- Validate against schemas
- Test error cases
- Check manifest generation

### 4. Keep It Simple

- Start with minimal implementation
- Add features incrementally
- Don't over-engineer

### 5. Make It Discoverable

- Add to Justfile
- Update README
- Include examples

---

## Examples Gallery

See these extensions for reference:

- **LLM Task**: `docs/schemas/llm_task.schema.json` + `scripts/run_llm_task.sh`
- **Mining Task**: `docs/schemas/mining_task.schema.json` + `scripts/mine_commits.sh`
- **Rust Tool**: `tools/rust_extractor/` + `flake.nix` package
- **Python Tool**: `tools/py_post/` + `flake.nix` devShell

---

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue
- **Extensions**: Share in Show & Tell

---

**Last Updated**: 2025-10-15
**Version**: 1.0
