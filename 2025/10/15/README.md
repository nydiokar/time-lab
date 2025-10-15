# Workspace: 2025/10/15

## Overview

Daily workspace created on 2025-10-15 12:32:38 UTC.

## Structure

- `ai-team/` - LLM tasks and experiments
  - `specs/` - Input specification files (JSON)
  - `artifacts/` - Output artifacts and run manifests
- `analyzer/` - Data analysis and processing
  - `inputs/` - Raw input data
  - `outputs/` - Processed results
- `knowledge/` - Notes and knowledge graphs
  - `notes.md` - Daily notes and observations
  - `graph/` - Knowledge graph artifacts

## Quick Start

```bash
# Run an LLM task
just ai spec=2025/10/15/ai-team/specs/demo.json

# Mine commits
just mine repo=owner/name limit=10

# Summarize a commit
just summ sha=abc123
```

## Notes

Add your daily observations and learnings here.
