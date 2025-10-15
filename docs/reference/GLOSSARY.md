# Glossary

Canonical definitions of Time-Lab terms to eliminate ambiguity.

## Core Concepts

### Artifact
**Definition**: Any file produced by a run (outputs, logs, intermediate results).

**Examples**:
- `output.jsonl` - LLM generated text
- `analysis_summary.md` - Human-readable analysis
- `run.json` - Run manifest (special artifact)

**Not Artifacts**: Input specs, source code

**Related**: [Manifest](#manifest), [Run](#run)

---

### Date Folder
**Definition**: A directory following the `YYYY/MM/DD` pattern that contains all work for a specific date.

**Structure**:
```
2025/10/15/
├── README.md
├── ai-team/
├── analyzer/
└── knowledge/
```

**Purpose**: Natural chronological organization matching research workflows.

**Related**: [Workspace](#workspace)

---

### DevShell
**Definition**: A Nix development environment (from `nix develop`) providing specific tools and dependencies.

**Examples**:
- `default` - Core utilities (jq, just, git)
- `rust_dev` - Rust toolchain
- `python_ml` - Python + ML libraries

**Usage**: `nix develop .#python_ml`

**Related**: [Profile](#profile), [Flake](#flake)

---

### Flake
**Definition**: A Nix file (`flake.nix`) declaring reproducible builds, environments, and packages with pinned dependencies.

**Outputs**:
- `devShells` - Development environments
- `packages` - Built binaries
- `apps` - Runnable applications
- `checks` - CI tests

**Lock File**: `flake.lock` pins all dependency versions.

**Related**: [DevShell](#devshell)

---

### Manifest
**Definition**: A `run.json` file documenting the provenance and metadata of a run.

**Required Fields**:
- `run_id` - Deterministic hash
- `timestamp_start` - UTC start time
- `git_sha` - Code version
- `flake_lock_sha256` - Dependency versions
- `status` - Execution status

**Purpose**: Reproducibility and traceability.

**Related**: [Run](#run), [Run ID](#run-id)

---

### Profile
**Definition**: A named configuration providing a specific set of tools/environment (synonym for DevShell).

**Usage**: Different workflows need different tools:
- Data mining → `data_mining` profile
- Rust development → `rust_dev` profile
- Python ML → `python_ml` profile

**Related**: [DevShell](#devshell)

---

### Run
**Definition**: A single execution of a task (LLM inference, commit analysis, etc.).

**Lifecycle**:
1. Read spec
2. Execute task
3. Write artifacts
4. Generate manifest

**Identity**: Uniquely identified by [Run ID](#run-id)

**Related**: [Spec](#spec), [Artifact](#artifact), [Manifest](#manifest)

---

### Run ID
**Definition**: A deterministic SHA-256 hash uniquely identifying a run.

**Formula**:
```bash
run_id = SHA256(
  spec_hash +
  git_sha +
  flake_lock_sha256 +
  utc_timestamp
)
```

**Properties**:
- Deterministic given inputs
- Unique per execution (timestamp)
- 64 hexadecimal characters

**Example**: `a3f5b2c1d4e6f789...` (truncated for display)

**Related**: [Manifest](#manifest), [Reproducibility](#reproducibility)

---

### Spec
**Definition**: A JSON input file describing what task to perform.

**Required Fields**:
- `kind` - Task type (llm, analysis, extraction, mining)
- `version` - Spec schema version

**Location**: `YYYY/MM/DD/*/specs/`

**Example**:
```json
{
  "kind": "llm",
  "version": "1.0",
  "inputs": { "prompt": "..." },
  "config": { "temperature": 0.7 }
}
```

**Related**: [Task](#task), [Run](#run)

---

### Task
**Definition**: A unit of work (LLM inference, data extraction, commit analysis).

**Types**:
- `llm` - Language model inference
- `analysis` - Data analysis
- `extraction` - Data extraction
- `mining` - Git commit mining

**Execution**: Driven by [Spec](#spec), produces [Artifacts](#artifact)

**Related**: [Spec](#spec), [Run](#run)

---

### Workspace
**Definition**: The complete environment for a specific date, including specs, artifacts, and knowledge.

**Structure**:
```
YYYY/MM/DD/              # Date folder
├── README.md            # Day summary
├── runs.csv             # Execution log
├── ai-team/             # LLM tasks
├── analyzer/            # Data analysis
└── knowledge/           # Notes and graphs
```

**Related**: [Date Folder](#date-folder)

---

## Technical Terms

### Deterministic Build
**Definition**: A build that produces identical outputs given identical inputs.

**Requirements**:
- Pinned dependencies (flake.lock)
- Reproducible timestamps (UTC)
- Logged random seeds
- No network access (or controlled)

**Limitations**: Not all operations are deterministic (LLM APIs, hardware differences).

---

### Provenance
**Definition**: The complete history and context of how an artifact was created.

**Captured In**: [Manifest](#manifest)

**Includes**:
- Code version (git SHA)
- Dependencies (flake.lock hash)
- Input spec
- Execution parameters
- Timestamps

**Purpose**: Reproducibility and debugging.

---

### Reproducibility
**Definition**: The ability to recreate the same results given the same inputs and environment.

**Time-Lab Approach**:
1. Pin all dependencies (Nix)
2. Log all parameters (manifests)
3. Record environment (git SHA, flake.lock)
4. Use UTC timestamps
5. Log random seeds

**Levels**:
- **Exact**: Bit-for-bit identical (rare)
- **Functional**: Same logical output (goal)
- **Approximate**: Similar results (LLM APIs)

---

### Schema
**Definition**: A JSON Schema document defining the structure and validation rules for specs or manifests.

**Location**: `docs/schemas/`

**Examples**:
- `run.schema.json` - Manifest structure
- `spec.schema.json` - Input spec structure
- `llm_task.schema.json` - LLM-specific spec

**Purpose**: Validation, documentation, tooling.

---

## Workflow Terms

### Daily Tree
**Definition**: The `YYYY/MM/DD/` folder structure for a specific date.

**Created By**: `just day` or `scripts/today.sh`

**Contains**: Workspace for all work on that date.

**Related**: [Workspace](#workspace), [Date Folder](#date-folder)

---

### Latest Symlink
**Definition**: A symbolic link pointing to the most recent date folder.

**Path**: `latest -> YYYY/MM/DD`

**Purpose**: Quick access to current work without typing date.

**Update**: Automatically by `today.sh` or `sync_latest.sh`

---

### Run Sequence
**Definition**: The ordered steps of executing a task:
1. Read spec
2. Validate spec against schema
3. Generate run ID
4. Create manifest (status: running)
5. Execute task
6. Write artifacts
7. Update manifest (status: ok/error)
8. Update runs.csv

---

## Directory Structure Terms

### ai-team/
**Definition**: Directory for LLM and AI agent tasks.

**Subdirectories**:
- `specs/` - Input specifications
- `artifacts/` - Outputs and manifests

**Location**: `YYYY/MM/DD/ai-team/`

---

### analyzer/
**Definition**: Directory for data analysis tasks (commit mining, log parsing).

**Subdirectories**:
- `inputs/` - Data to analyze
- `outputs/` - Analysis results

**Location**: `YYYY/MM/DD/analyzer/`

---

### knowledge/
**Definition**: Directory for human-readable notes, observations, and knowledge graphs.

**Contents**:
- `notes.md` - Daily notes
- `graph/` - Knowledge graph data

**Location**: `YYYY/MM/DD/knowledge/`

---

### scripts/
**Definition**: Directory containing automation scripts.

**Purpose**: High-level workflows (create folders, run tasks, mine commits).

**Language**: Bash with strict error handling.

**Location**: `scripts/` (repository root)

---

### tools/
**Definition**: Directory containing built tools and utilities.

**Subdirectories**:
- `rust_extractor/` - Rust-based extraction tools
- `py_post/` - Python post-processing tools

**Location**: `tools/` (repository root)

---

## File Types

### run.json
**Definition**: A manifest file documenting a single run.

**Schema**: `docs/schemas/run.schema.json`

**Naming**: `run_<first8chars>.json` (e.g., `run_a3f5b2c1.json`)

**Location**: Inside artifacts directory.

**Related**: [Manifest](#manifest)

---

### spec.json
**Definition**: An input specification file.

**Schema**: `docs/schemas/spec.schema.json` (base) + task-specific schemas

**Naming**: Descriptive (e.g., `quantum_explanation.json`)

**Location**: Inside specs directory.

**Related**: [Spec](#spec)

---

### runs.csv
**Definition**: A CSV file logging all runs for a date.

**Columns**: `run_id,timestamp_start,timestamp_end,cmd,status`

**Purpose**: Quick overview of daily activity.

**Location**: `YYYY/MM/DD/runs.csv`

---

## Status Values

### Run Status
**Definition**: The state of a run in the manifest.

**Values**:
- `running` - Currently executing
- `ok` - Completed successfully
- `error` - Failed with error
- `cancelled` - Manually stopped

**Field**: `manifest.status`

---

## Tool-Specific Terms

### LLM Task
**Definition**: A task involving language model inference.

**Spec Kind**: `llm`

**Parameters**:
- `temperature` - Randomness (0.0-2.0)
- `top_p` - Nucleus sampling
- `seed` - Random seed (if supported)
- `max_tokens` - Output length limit

**Related**: [Task](#task)

---

### Commit Mining
**Definition**: Extracting and analyzing git commits from a repository.

**Spec Kind**: `mining`

**Workflow**:
1. Fetch commits from GitHub API
2. For each commit:
   - Download diff
   - Extract statistics
   - Generate summary

**Output**: Folder per commit with analysis files.

---

## Nix-Specific Terms

### buildRustPackage
**Definition**: Nix function for building Rust projects.

**Requirements**:
- `Cargo.toml`
- `Cargo.lock`

**Usage**:
```nix
rustPlatform.buildRustPackage {
  pname = "my-tool";
  version = "1.0.0";
  src = ./path/to/tool;
  cargoLock.lockFile = ./path/to/Cargo.lock;
}
```

---

### mkShell
**Definition**: Nix function for creating development shells.

**Provides**: `buildInputs`, environment variables, shell hooks.

**Usage**:
```nix
pkgs.mkShell {
  buildInputs = [ pkgs.jq pkgs.git ];
  shellHook = "echo 'Welcome!'";
}
```

---

## Abbreviations

| Term | Full Form | Meaning |
|------|-----------|---------|
| ADR | Architectural Decision Record | Document explaining a design choice |
| CI | Continuous Integration | Automated testing on commits |
| UTC | Coordinated Universal Time | Timezone-independent timestamps |
| SHA | Secure Hash Algorithm | Cryptographic hash (git commits, file contents) |
| LLM | Large Language Model | AI model for text generation |
| ML | Machine Learning | AI/data science workflows |

---

## Anti-Patterns (What NOT to call things)

❌ **Job** → Use [Task](#task) or [Run](#run)  
❌ **Experiment** → Use [Run](#run) (more specific)  
❌ **Output** → Use [Artifact](#artifact) (clearer)  
❌ **Config** → Use [Spec](#spec) for inputs, "Manifest" for outputs  
❌ **Profile** and "Shell" → Both refer to [DevShell](#devshell), use "DevShell" in code  

---

## Term Relationships

```
Spec (input)
  ↓
Task (what to do)
  ↓
Run (execution)
  ↓
Artifacts (outputs)
  ↓
Manifest (provenance)
```

```
Flake
  ├── DevShells (profiles)
  ├── Packages (built tools)
  └── Apps (runnable tasks)
```

```
Workspace (date folder)
  ├── ai-team/
  │   ├── specs/
  │   └── artifacts/ (manifests here)
  ├── analyzer/
  └── knowledge/
```

---

## Usage Examples

### Correct Usage ✅

- "Check the **manifest** to see which model version was used"
- "Create a **spec** for the LLM task"
- "Enter the **rust_dev devShell** to compile the tool"
- "The **run ID** is deterministic given the same inputs"
- "Store **artifacts** in the date folder"

### Incorrect Usage ❌

- "Check the config to see..." → Use "manifest"
- "Write a job definition" → Use "spec"
- "Use the Rust profile" → Use "rust_dev devShell"
- "The experiment ID is..." → Use "run ID"
- "The outputs are in..." → Use "artifacts"

---

## Glossary Maintenance

When adding new terms:
1. Define clearly (one sentence if possible)
2. Provide examples
3. Link to related terms
4. Show usage (correct and incorrect)
5. Update relationships diagram if needed

---

**Last Updated**: 2025-10-15  
**Status**: v1.0 - Canonical definitions

