#!/usr/bin/env bash
# Summarize a git diff or commit
# Usage: ./summarize_diff.sh <commit-sha>

set -Eeuo pipefail
IFS=$'\n\t'

COMMIT_SHA="${1:-}"

if [ -z "$COMMIT_SHA" ]; then
  echo "❌ Error: Commit SHA required"
  echo "Usage: $0 <commit-sha>"
  exit 64
fi

echo "📝 Summarizing Commit"
echo "===================="
echo "SHA: $COMMIT_SHA"
echo ""

# Create today's analyzer directory
TODAY=$(date -u +%Y/%m/%d)
ANALYZER_DIR="${TODAY}/analyzer/outputs"
mkdir -p "$ANALYZER_DIR"

OUTPUT_FILE="${ANALYZER_DIR}/summary_${COMMIT_SHA}.md"

# Get commit info from current repo (if available)
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git cat-file -e "${COMMIT_SHA}^{commit}" 2>/dev/null; then
    cat > "$OUTPUT_FILE" << EOF
# Commit Summary: ${COMMIT_SHA}

## Metadata

- **SHA**: ${COMMIT_SHA}
- **Author**: $(git log -1 --format='%an <%ae>' "$COMMIT_SHA")
- **Date**: $(git log -1 --format='%ai' "$COMMIT_SHA")
- **Summary**: $(git log -1 --format='%s' "$COMMIT_SHA")

## Commit Message

\`\`\`
$(git log -1 --format='%B' "$COMMIT_SHA")
\`\`\`

## Diff Stats

\`\`\`
$(git show --stat "$COMMIT_SHA")
\`\`\`

## Analysis

TODO: Add AI-generated analysis here

## Changes

<details>
<summary>Full diff</summary>

\`\`\`diff
$(git show "$COMMIT_SHA")
\`\`\`

</details>

---

Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
    echo "✅ Summary created: $OUTPUT_FILE"
  else
    echo "❌ Commit not found in current repository: $COMMIT_SHA"
    exit 65
  fi
else
  echo "⚠️  Not in a git repository"
  echo "Creating placeholder summary..."

  cat > "$OUTPUT_FILE" << EOF
# Commit Summary: ${COMMIT_SHA}

## Note

Summary created outside of git repository.

To populate with actual data:
1. Run from within a git repository, OR
2. Implement remote repository fetching

---

Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
  echo "✅ Placeholder summary created: $OUTPUT_FILE"
fi

echo ""
echo "📄 View: cat $OUTPUT_FILE"
