# Time-Lab Justfile
# Common task automation for daily workflows
#
# Usage: just <command>
# List all commands: just --list

# Default recipe shows help
default:
    @just --list

# Create today's workspace structure (YYYY/MM/DD)
day:
    @echo "📅 Creating today's workspace..."
    @bash scripts/today.sh

# Run an LLM task from a spec file
# Usage: just ai spec=2025/10/15/ai-team/specs/demo.json
ai spec:
    @echo "🤖 Running LLM task: {{spec}}"
    @bash scripts/run_llm_task.sh "{{spec}}"

# Mine commits from a git repository
# Usage: just mine repo=owner/repo limit=10
mine repo limit="10":
    @echo "⛏️  Mining commits from {{repo}}..."
    @bash scripts/mine_commits.sh "{{repo}}" "{{limit}}"

# Summarize a git diff/commit
# Usage: just summ sha=abcd123
summ sha:
    @echo "📝 Summarizing commit {{sha}}..."
    @bash scripts/summarize_diff.sh "{{sha}}"

# Update latest/ symlinks to most recent date
sync:
    @echo "🔄 Syncing latest/ symlinks..."
    @bash scripts/sync_latest.sh

# Check all shell scripts with shellcheck
check:
    @echo "🔍 Running shellcheck on all scripts..."
    @find scripts -name "*.sh" -type f -exec shellcheck {} +
    @echo "✅ All scripts passed shellcheck!"

# Format all shell scripts with shfmt
fmt:
    @echo "✨ Formatting shell scripts..."
    @find scripts -name "*.sh" -type f -exec shfmt -w -i 2 -ci {} +
    @echo "✅ Scripts formatted!"

# Show git status and recent runs
status:
    @echo "📊 Repository Status"
    @echo "===================="
    @echo ""
    @echo "Git:"
    @git status -s || echo "  (no changes)"
    @echo ""
    @echo "Recent Workspaces:"
    @find . -maxdepth 3 -type d -name "[0-9][0-9]" 2>/dev/null | sort -r | head -5 || echo "  (none yet)"
    @echo ""
    @if [ -f "runs.csv" ]; then \
        echo "Recent Runs:"; \
        tail -5 runs.csv; \
    fi

# Clean up old artifacts (interactive)
clean:
    @echo "⚠️  This will show you what can be cleaned"
    @echo ""
    @echo "Temporary files:"
    @find . -name "*.tmp" -o -name "*.log" | head -10 || echo "  (none found)"
    @echo ""
    @echo "To delete, run: find . -name '*.tmp' -delete"

# Initialize a new spec file template
init-spec name:
    #!/usr/bin/env bash
    set -euo pipefail
    TODAY=$(date -u +%Y/%m/%d)
    SPEC_DIR="${TODAY}/ai-team/specs"
    SPEC_FILE="${SPEC_DIR}/{{name}}.json"

    mkdir -p "${SPEC_DIR}"

    cat > "${SPEC_FILE}" << 'EOF'
    {
      "task": "{{name}}",
      "model": "ollama:qwen2.5:7b",
      "parameters": {
        "temperature": 0.2,
        "top_p": 0.95,
        "seed": 1234,
        "max_tokens": 2048
      },
      "prompt": "Your prompt here",
      "output_format": "json"
    }
    EOF

    echo "✅ Created spec: ${SPEC_FILE}"

# Run flake checks
test:
    @echo "🧪 Running Nix flake checks..."
    nix flake check

# Update flake.lock dependencies
update:
    @echo "⬆️  Updating flake.lock..."
    nix flake update
    @echo "✅ Dependencies updated. Review changes with: git diff flake.lock"

# Show development environment info
info:
    @echo "ℹ️  Environment Information"
    @echo "=========================="
    @echo ""
    @echo "Nix:     $(nix --version)"
    @echo "Git:     $(git --version)"
    @echo "Just:    $(just --version)"
    @echo ""
    @if command -v rustc &> /dev/null; then \
        echo "Rust:    $(rustc --version)"; \
    fi
    @if command -v python &> /dev/null; then \
        echo "Python:  $(python --version)"; \
    fi
    @echo ""
    @echo "Flake metadata:"
    @nix flake metadata --json | jq -r '.url, .locked.rev[0:7]'
