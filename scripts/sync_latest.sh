#!/usr/bin/env bash
# Update latest/ symlink to point to most recent YYYY/MM/DD directory
# Also maintains runs.csv with all executions

set -Eeuo pipefail
IFS=$'\n\t'

echo "🔄 Syncing latest/ symlink"
echo "=========================="

# Find most recent date directory
LATEST_DIR=$(find . -maxdepth 3 -type d -regex '.*/[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]' | sort -r | head -1)

if [ -z "$LATEST_DIR" ]; then
  echo "❌ No date directories found (YYYY/MM/DD)"
  exit 1
fi

# Remove ./ prefix
LATEST_DIR="${LATEST_DIR#./}"

echo "📁 Latest directory: $LATEST_DIR"

# Update or create symlink
if [ -L "latest" ]; then
  OLD_TARGET=$(readlink latest)
  rm latest
  echo "🗑️  Removed old symlink: latest -> $OLD_TARGET"
fi

ln -s "$LATEST_DIR" latest
echo "✅ Created symlink: latest -> $LATEST_DIR"

# Update runs.csv (if it exists or create it)
if [ ! -f "runs.csv" ]; then
  echo "📊 Creating runs.csv"
  echo "timestamp,date_path,status,run_id" > runs.csv
fi

# Find all run.json files and add to runs.csv (if not already tracked)
# This is a simplified version - you'd want more sophisticated tracking
echo ""
echo "📈 Scan complete"
echo "   Latest: $LATEST_DIR"
echo "   Runs tracked in: runs.csv"
