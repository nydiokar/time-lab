#!/usr/bin/env bash
# Run an LLM task from a specification file
# Usage: ./run_llm_task.sh path/to/spec.json

set -Eeuo pipefail
IFS=$'\n\t'

SPEC_FILE="${1:-}"

if [ -z "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file required"
  echo "Usage: $0 <spec-file.json>"
  exit 64
fi

if [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 65
fi

echo "🤖 Running LLM Task"
echo "=================="
echo "Spec: $SPEC_FILE"
echo ""

# Extract spec directory to determine output location
SPEC_DIR=$(dirname "$SPEC_FILE")
BASE_DIR="${SPEC_DIR%%/ai-team/specs*}"
ARTIFACTS_DIR="${BASE_DIR}/ai-team/artifacts"

mkdir -p "$ARTIFACTS_DIR"

# Generate run ID (simplified for now)
RUN_ID="run_$(date -u +%Y%m%d_%H%M%S)_$(echo $RANDOM | sha256sum | head -c 8)"

# Create run directory
RUN_DIR="${ARTIFACTS_DIR}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

# Copy spec to run directory
cp "$SPEC_FILE" "${RUN_DIR}/input.spec.json"

# Start timestamp
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "📝 Run ID: $RUN_ID"
echo "📂 Output: $RUN_DIR"
echo "⏰ Start: $START_TIME"
echo ""

# TODO: Actual LLM call would go here
# For now, create a placeholder manifest

# End timestamp
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create run manifest
cat > "${RUN_DIR}/run.json" << EOF
{
  "run_id": "${RUN_ID}",
  "timestamp_start": "${START_TIME}",
  "timestamp_end": "${END_TIME}",
  "spec_file": "${SPEC_FILE}",
  "status": "placeholder",
  "note": "LLM execution not yet implemented - this is a template",
  "git_sha": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "env": {
    "system": "$(uname -s)-$(uname -m)",
    "user": "${USER}"
  }
}
EOF

echo "✅ Run manifest created: ${RUN_DIR}/run.json"
echo ""
echo "⚠️  Note: LLM execution not yet implemented."
echo "   This script creates the structure and manifest template."
echo ""
echo "📋 To implement actual LLM calls:"
echo "   1. Add API client (OpenAI, Anthropic, Ollama, etc.)"
echo "   2. Parse spec.json for model parameters"
echo "   3. Execute API call with deterministic settings"
echo "   4. Save response to ${RUN_DIR}/output.json"
