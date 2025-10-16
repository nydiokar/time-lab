# JSON Schemas

This directory contains JSON Schema definitions for validating specs and manifests in Time-Lab.

## Schema Files

### Core Schemas

| Schema | Purpose | Used For |
|--------|---------|----------|
| [`spec.schema.json`](spec.schema.json) | Base specification | All task specs (base schema) |
| [`run.schema.json`](run.schema.json) | Run manifest | All run manifests |

### Task-Specific Schemas

| Schema | Purpose | Extends |
|--------|---------|---------|
| [`llm_task.schema.json`](llm_task.schema.json) | LLM inference tasks | `spec.schema.json` |
| [`mining_task.schema.json`](mining_task.schema.json) | Git commit mining | `spec.schema.json` |

## Usage

### Validating a Spec

```bash
# Using jq (basic validation)
jq -e . < my_spec.json

# Using ajv-cli (full schema validation)
npm install -g ajv-cli
ajv validate -s docs/schemas/llm_task.schema.json -d my_llm_spec.json
```

### Validating a Manifest

```bash
ajv validate -s docs/schemas/run.schema.json -d run_abc123.json
```

### In Python

```python
import json
import jsonschema

# Load schema
with open('docs/schemas/llm_task.schema.json') as f:
    schema = json.load(f)

# Load spec
with open('my_spec.json') as f:
    spec = json.load(f)

# Validate
jsonschema.validate(instance=spec, schema=schema)
print("✅ Valid!")
```

### In Rust

```rust
use jsonschema::JSONSchema;
use serde_json::Value;

let schema_str = std::fs::read_to_string("docs/schemas/run.schema.json")?;
let schema: Value = serde_json::from_str(&schema_str)?;
let compiled = JSONSchema::compile(&schema)?;

let manifest_str = std::fs::read_to_string("run.json")?;
let manifest: Value = serde_json::from_str(&manifest_str)?;

if compiled.is_valid(&manifest) {
    println!("✅ Valid!");
} else {
    for error in compiled.validate(&manifest).unwrap_err() {
        eprintln!("❌ {}", error);
    }
}
```

## Schema Relationships

```
spec.schema.json (base)
  ├── llm_task.schema.json (extends via allOf)
  ├── mining_task.schema.json (extends via allOf)
  ├── analysis_task.schema.json (future)
  └── extraction_task.schema.json (future)

run.schema.json (standalone)
```

## Creating a New Task Schema

1. **Create schema file**: `docs/schemas/my_task.schema.json`

2. **Extend base spec**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://time-lab.dev/schemas/my_task.schema.json",
  "title": "My Task Specification",
  "allOf": [
    {
      "$ref": "spec.schema.json"
    },
    {
      "type": "object",
      "properties": {
        "kind": {
          "const": "my_task"
        },
        "inputs": {
          "type": "object",
          "required": ["my_required_field"],
          "properties": {
            "my_required_field": {
              "type": "string",
              "description": "What this field does"
            }
          }
        }
      }
    }
  ]
}
```

3. **Add examples** in the schema

4. **Document** in this README

5. **Add validation** to scripts

## Example Files

### Example LLM Spec

```json
{
  "kind": "llm",
  "version": "1.0",
  "name": "Explain Quantum Computing",
  "inputs": {
    "prompt": "Explain quantum computing in simple terms"
  },
  "config": {
    "model": "ollama:qwen2.5:7b",
    "temperature": 0.7,
    "seed": 42,
    "max_tokens": 1000
  }
}
```

### Example Run Manifest

```json
{
  "run_id": "a3f5b2c1d4e6f789012345678901234567890123456789012345678901234567",
  "timestamp_start": "2025-10-15T14:30:00Z",
  "timestamp_end": "2025-10-15T14:30:45Z",
  "cmd": "./scripts/run_llm_task.sh spec.json",
  "git_sha": "abcd123",
  "flake_lock_sha256": "efgh456...",
  "task": {
    "kind": "llm",
    "spec_path": "2025/10/15/ai-team/specs/demo.json",
    "spec_hash": "1234567..."
  },
  "model": {
    "name": "ollama:qwen2.5:7b",
    "params": {
      "temperature": 0.7,
      "seed": 42
    }
  },
  "status": "ok",
  "artifacts": ["output.jsonl", "log.txt"]
}
```

## Schema Versioning

Schemas follow semantic versioning:

- **Major**: Breaking changes (remove required fields, change types)
- **Minor**: Backwards-compatible additions (new optional fields)
- **Patch**: Documentation, examples, clarifications

Current versions:
- `spec.schema.json`: 1.0
- `run.schema.json`: 1.0
- `llm_task.schema.json`: 1.0
- `mining_task.schema.json`: 1.0

## Validation in Scripts

Scripts should validate specs before execution:

```bash
# In run_llm_task.sh
validate_spec() {
  local spec_file="$1"

  # Basic JSON validation
  if ! jq empty "$spec_file" 2>/dev/null; then
    echo "Error: Invalid JSON in spec file" >&2
    return 65
  fi

  # Schema validation (if ajv is available)
  if command -v ajv &> /dev/null; then
    local kind=$(jq -r '.kind' "$spec_file")
    local schema="docs/schemas/${kind}_task.schema.json"

    if [ -f "$schema" ]; then
      if ! ajv validate -s "$schema" -d "$spec_file" 2>/dev/null; then
        echo "Error: Spec does not match schema: $schema" >&2
        return 65
      fi
    fi
  fi

  return 0
}
```

## IDE Integration

### VS Code

Add to `.vscode/settings.json`:

```json
{
  "json.schemas": [
    {
      "fileMatch": ["**/specs/*_llm.json", "**/specs/llm_*.json"],
      "url": "./docs/schemas/llm_task.schema.json"
    },
    {
      "fileMatch": ["**/specs/*_mining.json", "**/specs/mining_*.json"],
      "url": "./docs/schemas/mining_task.schema.json"
    },
    {
      "fileMatch": ["**/artifacts/run_*.json"],
      "url": "./docs/schemas/run.schema.json"
    }
  ]
}
```

Now you get autocomplete and validation in the editor!

## Testing Schemas

```bash
# Test that examples in schemas are valid
cd docs/schemas

for schema in *_task.schema.json; do
  echo "Testing $schema..."
  # Extract and validate examples (requires jq + ajv)
  jq -r '.examples[]' "$schema" | while read -r example; do
    echo "$example" | ajv validate -s "$schema" -d -
  done
done
```

## Future Schemas

Planned but not yet implemented:

- `analysis_task.schema.json` - Data analysis tasks
- `extraction_task.schema.json` - Data extraction tasks
- `pipeline.schema.json` - Multi-step pipelines
- `workflow.schema.json` - Complex workflows

## Contributing

When adding a new schema:

1. Follow existing patterns (use `allOf` for extending)
2. Include comprehensive examples
3. Add validation tests
4. Update this README
5. Document in GLOSSARY.md

---

**Last Updated**: 2025-10-15
**Schema Version**: 1.0
