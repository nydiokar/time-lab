#!/usr/bin/env bash
# Create today's workspace structure
# Creates: YYYY/MM/DD/ai-team/{specs,artifacts}
#          YYYY/MM/DD/analyzer/{inputs,outputs}
#          YYYY/MM/DD/knowledge/{notes.md,graph}

set -Eeuo pipefail
IFS=$'\n\t'

# Use UTC for determinism
TODAY=$(date -u +%Y/%m/%d)
YEAR=$(date -u +%Y)
MONTH=$(date -u +%m)
DAY=$(date -u +%d)

echo "📅 Creating workspace for ${TODAY}"

# Create directory structure
mkdir -p "${TODAY}/ai-team/specs"
mkdir -p "${TODAY}/ai-team/artifacts"
mkdir -p "${TODAY}/analyzer/inputs"
mkdir -p "${TODAY}/analyzer/outputs"
mkdir -p "${TODAY}/knowledge/graph"

# Create daily README if it doesn't exist
if [ ! -f "${TODAY}/README.md" ]; then
  cat > "${TODAY}/README.md" << EOF
# Workspace: ${TODAY}

## Overview

Daily workspace created on $(date -u +"%Y-%m-%d %H:%M:%S UTC").

## Structure

- \`ai-team/\` - LLM tasks and experiments
  - \`specs/\` - Input specification files (JSON)
  - \`artifacts/\` - Output artifacts and run manifests
- \`analyzer/\` - Data analysis and processing
  - \`inputs/\` - Raw input data
  - \`outputs/\` - Processed results
- \`knowledge/\` - Notes and knowledge graphs
  - \`notes.md\` - Daily notes and observations
  - \`graph/\` - Knowledge graph artifacts

## Quick Start

\`\`\`bash
# Run an LLM task
just ai spec=${TODAY}/ai-team/specs/demo.json

# Mine commits
just mine repo=owner/name limit=10

# Summarize a commit
just summ sha=abc123
\`\`\`

## Notes

Add your daily observations and learnings here.
EOF
fi

# Create knowledge notes if it doesn't exist
if [ ! -f "${TODAY}/knowledge/notes.md" ]; then
  cat > "${TODAY}/knowledge/notes.md" << EOF
# Notes: ${TODAY}

## Experiments

- 

## Learnings

- 

## Next Steps

- 

## References

- 
EOF
fi

# Update latest/ symlink
if [ -L "latest" ]; then
  rm latest
fi
ln -s "${TODAY}" latest

echo "✅ Workspace created: ${TODAY}"
echo "📁 Structure:"
tree -L 3 "${TODAY}" 2>/dev/null || find "${TODAY}" -type d | sed 's|[^/]*/|  |g'
echo ""
echo "🔗 Symlink: latest -> ${TODAY}"
echo ""
echo "📝 Next: Create a spec file with 'just init-spec <name>'"

