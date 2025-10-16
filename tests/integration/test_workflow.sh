#!/usr/bin/env bash
# Integration test: End-to-end workflow

set -Eeuo pipefail

echo "🧪 Running integration tests..."

# Test 1: Create workspace
echo "Test 1: Create workspace"
./scripts/today.sh 2025-10-16
[ -d "2025/10/16" ] || exit 1
echo "✅ Pass"

# Test 2: Run LLM task
echo "Test 2: Run LLM task"
mkdir -p 2025/10/16/ai-team/specs
echo '{"kind":"llm","version":"1.0","inputs":{}}' > 2025/10/16/ai-team/specs/test.json
./scripts/run_llm_task.sh 2025/10/16/ai-team/specs/test.json
[ -d 2025/10/16/ai-team/artifacts/run_* ] || exit 1
echo "✅ Pass"

# Test 3: Validate manifest
echo "Test 3: Validate manifest"
MANIFEST=$(find 2025/10/16/ai-team/artifacts -name "run.json" | head -1)
jq -e '.run_id' "$MANIFEST" > /dev/null || exit 1
echo "✅ Pass"

echo "🎉 All tests passed!"
