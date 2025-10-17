# Vision: Personal AI Development Ecosystem

**Created**: 2025-10-17
**Status**: Foundation Phase
**Philosophy**: Build leverage, not features. Experiment to learn, systematize to scale.

---

## 🎯 Purpose: Why This Exists

### The Problem

As a developer managing multiple concurrent projects (auth module, crypto analyzer, Discord LLM, Android STT app, learning systems), I face:

1. **Context Switching Cost** - Each project requires mental reload, losing momentum
2. **Lost Institutional Memory** - Insights and attempts scatter across repos, branches, and memory
3. **Repeated Manual Work** - Same LLM prompts, same debugging patterns, no learning
4. **Fragile Environments** - "It worked on Windows" → breaks on Linux → hours wasted
5. **No Leverage** - Building from scratch each time, no accumulated advantage

### The Solution

A **three-layer architecture** that separates concerns while enabling synergy:

```
Layer 1: Projects        = The actual work (auth, crypto, STT, etc.)
Layer 2: AI-Team         = Automation orchestrator (watches, executes, learns)
Layer 3: Time-Lab        = Historical memory (artifacts, insights, queries)
```

**Not** a monorepo. **Not** a framework. **Not** a product.

**It is**: A personal ecosystem that compounds learning across projects.

---

## 🧠 Core Insight: Separation of Concerns

### What This Is NOT

- ❌ **Not time-2025 reproduction** - That's a journal; this is an operating system
- ❌ **Not over-engineering** - Each layer has clear purpose and boundaries
- ❌ **Not premature optimization** - Build for current needs, expand as they grow
- ❌ **Not a product** - Built for personal advantage, shared if useful to others

### What This IS

- ✅ **Operating System for Solo Dev** - Infrastructure that makes building faster
- ✅ **Learning Accumulator** - Captures what works, what doesn't, why
- ✅ **Reproducibility Engine** - Time-travel to any environment/build state
- ✅ **AI Leverage Multiplier** - One daemon helping all projects, learning from all

---

## 🏗️ Architecture: Three Independent Layers

### Layer 1: Projects (The Work)

```
~/projects/
├── auth-module/              # Lean authentication service
│   ├── flake.nix             # Own deps: FastAPI, SQLAlchemy
│   ├── .envrc                # direnv: use flake
│   └── .ai-team/             # Optional: AI assistance config
│       └── tasks/            # Drop .task.md files here
│
├── crypto-analyzer/          # Wallet analysis tool
│   ├── flake.nix             # Own deps: pandas, web3.py
│   └── .ai-team/
│
├── discord-llm/              # Multi-platform bot
│   ├── flake.nix             # Own deps: discord.py, telegram-bot
│   └── .ai-team/
│
├── android-stt/              # Whisper-based voice app
│   ├── flake.nix             # Own deps: Android SDK, Rust
│   └── .ai-team/
│
└── spell-devices/            # Learning system experiments
    ├── flake.nix
    └── .ai-team/
```

**Principles:**
- Each project is **independent** - own repo, own deps, own flake
- Each project is **unaware** of AI-team or time-lab (zero coupling)
- AI assistance is **opt-in** - add `.ai-team/` when needed
- Environment is **reproducible** - `nix develop` always works

**Why This Works:**
- No dependency conflicts (auth doesn't need crypto's pandas)
- Fast Nix builds (only rebuild what changed)
- Portable (share auth-module without entire ecosystem)
- Low cognitive load (each project stands alone)

---

### Layer 2: AI-Team (The Automation)

```
~/AI-team/
├── flake.nix                 # Deps: Python 3.11, Ollama, watchdog
├── pyproject.toml            # Core deps (pydantic, pyyaml, ollama)
├── .env                      # Config (no hardcoded paths)
│   ├── CLAUDE_BASE_CWD=/home/gorila/projects
│   ├── ARTIFACT_BACKEND=time-lab
│   ├── ARTIFACT_PATH=/home/gorila/time-lab
│   ├── OLLAMA_MODEL=llama3.2:latest
│   └── WATCH_PATTERNS=**/.ai-team/tasks/*.task.md
│
├── src/
│   ├── orchestrator.py       # Main daemon
│   ├── core/
│   │   ├── file_watcher.py   # Watches for .task.md files
│   │   ├── task_parser.py    # Parses YAML + Markdown
│   │   └── git_automation.py # Detects changes, creates commits
│   ├── bridges/
│   │   ├── claude_bridge.py  # Executes Claude Code CLI
│   │   └── llama_mediator.py # Local parsing/summarization
│   ├── validation/
│   │   └── engine.py         # Similarity, entropy checks
│   └── adapters/
│       └── time_lab.py       # NEW: Protocol for writing to time-lab
│
├── prompts/
│   ├── general_prompt_coding.md
│   └── agents/
│       ├── fix.md
│       ├── code_review.md
│       ├── analyze.md
│       └── documentation.md
│
├── logs/                     # Ephemeral (7-day retention)
│   ├── events.ndjson         # Timestamped execution log
│   └── state.json            # Recovery state for restarts
│
└── results/                  # Ephemeral (local cache)
    └── task_abc123.json      # Full execution results
```

**Current State:**
- ✅ **Works on Windows** - Tested, functional
- ⚠️ **Linux adaptation needed** - Remove hardcoded `C:\Users\...` paths
- ✅ **Core features complete** - File watching, Claude integration, LLAMA mediation
- ⚠️ **Integration incomplete** - No time-lab protocol yet

**Key Capabilities:**
1. **Watches all projects** - One daemon, `~/projects/**/.ai-team/tasks/`
2. **Context-aware execution** - Runs in project's directory with project's environment
3. **Hybrid intelligence** - LLAMA for parsing/summarization, Claude for execution
4. **Graceful degradation** - If LLAMA unavailable, falls back to regex/templates
5. **Event-driven logging** - NDJSON append-only log for observability

**Why Daemon Architecture:**
- Background process, always ready
- Watches multiple projects simultaneously
- No manual invocation needed (drop file → work happens)
- Survives across shell sessions

---

### Layer 3: Time-Lab (The Memory)

```
~/time-lab/
├── flake.nix                 # Minimal deps: jq, just, git, ripgrep
├── Justfile                  # Query and management commands
│   ├── just show 2025/10/17  # Show day's artifacts
│   ├── just query "login"    # Search across projects
│   ├── just record           # Accept new artifact
│   └── just stats            # Usage statistics
│
├── schemas/                  # Artifact validation
│   ├── artifact.schema.json  # What AI-team writes
│   ├── run.schema.json       # Execution manifest
│   └── spec.schema.json      # Task specification
│
├── scripts/
│   ├── record.sh             # Accept artifact, organize by date
│   ├── query.sh              # Search artifacts
│   └── index.sh              # Rebuild search index
│
├── YYYY/MM/DD/               # Date-organized artifacts
│   ├── auth-module/
│   │   ├── task_abc123/
│   │   │   ├── artifact.json # What was done
│   │   │   ├── summary.txt   # Human-readable
│   │   │   └── context.json  # Git state, env, timing
│   │   └── task_def456/
│   ├── crypto-analyzer/
│   ├── discord-llm/
│   └── index.json            # Day's work summary
│
└── .index/                   # Search indices (gitignored)
    ├── by_project.json
    ├── by_task_type.json
    └── full_text.idx
```

**Design Principles:**
- **Dumb storage** - No business logic, just accept and organize
- **Schema-driven** - Validate artifacts on write
- **Date-organized** - Natural "what did I do on X?" queries
- **Project-partitioned** - Keep auth separate from crypto
- **Queryable** - Fast search without loading everything

**Why NOT in AI-team?**
- AI-team logs are ephemeral (debugging, monitoring)
- time-lab artifacts are permanent (learning, reference)
- Different retention policies (7 days vs forever)
- Different purposes (execution vs insight)

---

## 🔗 Integration Protocol: How Layers Connect

### AI-Team → Time-Lab Communication

**Simple, decoupled, data-only:**

```python
# In AI-team: src/adapters/time_lab.py

class TimeLab:
    def __init__(self, base_path: str):
        self.base = Path(base_path)

    def record_artifact(
        self,
        date: str,              # "2025/10/17"
        project: str,           # "auth-module"
        task_id: str,           # "task_abc123"
        artifact: dict          # Structured result
    ):
        # Construct path: time-lab/2025/10/17/auth-module/task_abc123/
        path = self.base / date / project / task_id
        path.mkdir(parents=True, exist_ok=True)

        # Write artifact.json
        with open(path / "artifact.json", "w") as f:
            json.dump(artifact, f, indent=2)

        # Write human summary
        with open(path / "summary.txt", "w") as f:
            f.write(artifact.get("summary", "No summary"))

        # Update day's index
        self._update_index(date, project, task_id, artifact)
```

**What gets written:**

```json
// time-lab/2025/10/17/auth-module/task_abc123/artifact.json
{
  "task_id": "task_abc123",
  "timestamp": "2025-10-17T14:23:45Z",
  "project": "auth-module",
  "task_type": "fix",
  "summary": "Fixed login session expiry bug",
  "duration_seconds": 12.3,
  "files_changed": ["src/auth.py", "tests/test_auth.py"],
  "git": {
    "sha_before": "abc123",
    "sha_after": "def456",
    "branch": "main"
  },
  "claude": {
    "model": "claude-sonnet-4-5",
    "turns": 1,
    "tools_used": ["Read", "Edit", "Bash"]
  },
  "validation": {
    "similarity": 0.87,
    "entropy": 0.72,
    "issues": []
  },
  "result": "success"
}
```

**No coupling:**
- AI-team doesn't import time-lab code
- Time-lab doesn't know about AI-team
- Communication is file-system writes (simple, debuggable)
- Either can be swapped without breaking the other

---

## 📋 Path Forward: Phased Execution

### Phase 0: Solidify AI-Team (Current - Week 1-2)

**Goal:** Make AI-team production-ready on Linux

**Tasks:**
1. ✅ AI-team works on Windows (DONE)
2. ⚠️ Remove hardcoded Windows paths
   - `settings.py:98` → Use `CLAUDE_BASE_CWD` env var
   - Test with Linux paths (`/home/gorila/projects`)
3. ⚠️ Test on WSL2/Linux
   - Verify watchdog works
   - Verify Claude CLI integration
   - Verify LLAMA/Ollama connection
4. ⚠️ Document configuration
   - `.env.example` with all required vars
   - Setup instructions for Linux
   - Troubleshooting guide

**Success Criteria:**
- AI-team daemon starts successfully on Linux
- Watches `~/projects/**/.ai-team/tasks/` correctly
- Executes test task via Claude
- Writes results to `AI-team/results/`

**Blockers:**
- None (Windows version works, Linux is minor adaptation)

---

### Phase 1: Prepare Time-Lab (Week 2-3)

**Goal:** Make time-lab ready to receive artifacts

**Tasks:**
1. ✅ Basic structure exists (DONE - flake, schemas, scripts)
2. ⚠️ Add artifact schema validation
   - `schemas/artifact.schema.json` - Define expected structure
   - `scripts/record.sh` - Validate on write
3. ⚠️ Implement record script
   - Accept artifact via stdin or file path
   - Organize by date and project
   - Update index
4. ⚠️ Add query commands
   - `just show <date>` - Show day's work
   - `just query <term>` - Search across projects
   - `just stats` - Usage statistics
5. ⚠️ Test manually
   - Create fake artifact
   - Record it
   - Query it back

**Success Criteria:**
- Can manually record artifact: `echo '...' | just record`
- Can query by date: `just show 2025/10/17`
- Can search: `just query "login bug"`
- Artifacts persist and are human-readable

**Deliverables:**
- Working `scripts/record.sh`
- Working `Justfile` commands
- Validated artifact schema
- Example artifacts for testing

---

### Phase 2: Connect AI-Team ↔ Time-Lab (Week 3-4)

**Goal:** AI-team writes to time-lab automatically

**Tasks:**
1. ⚠️ Create `AI-team/src/adapters/time_lab.py`
   - Implement `record_artifact()` method
   - Handle path construction
   - Handle errors gracefully
2. ⚠️ Integrate into orchestrator
   - After task completes, call `time_lab.record_artifact()`
   - Keep AI-team's own logs (separate from time-lab)
   - Log success/failure
3. ⚠️ Test end-to-end
   - Drop task in test project
   - Verify AI-team executes
   - Verify artifact appears in time-lab
   - Verify query works
4. ⚠️ Add configuration
   - `AI-team/.env` → `ARTIFACT_BACKEND=time-lab`
   - `AI-team/.env` → `ARTIFACT_PATH=/home/gorila/time-lab`
   - Document setup

**Success Criteria:**
- Drop `.task.md` in project
- AI-team processes it
- Artifact appears in `time-lab/YYYY/MM/DD/project/`
- No manual intervention needed

**Example Flow:**
```bash
# Setup (one time)
cd ~/AI-team
nix develop --command orchestrator daemon \
  --watch ~/projects \
  --artifacts ~/time-lab &

# Use it
cd ~/auth-module
echo "Fix login bug" > .ai-team/tasks/fix.task.md
# (AI-team detects, processes, writes to time-lab)

# Query later
cd ~/time-lab
just query "login"
# → Found: 2025/10/17/auth-module/task_abc123
```

---

### Phase 3: Multi-Project Validation (Week 4-5)

**Goal:** Prove it works across multiple projects

**Tasks:**
1. ⚠️ Add `.ai-team/` to 3 existing projects
   - auth-module
   - crypto-analyzer
   - discord-llm (or another active one)
2. ⚠️ Create test tasks for each
   - auth: "Add password reset endpoint"
   - crypto: "Analyze gas fees for last 30 days"
   - discord: "Add /help command"
3. ⚠️ Let AI-team process all three
   - Verify context switching works
   - Verify artifacts separated correctly
   - Verify no cross-project pollution
4. ⚠️ Query across projects
   - `just query "endpoint"` - Should find auth task
   - `just show 2025/10/17` - Should show all three

**Success Criteria:**
- AI-team handles 3 projects simultaneously
- Artifacts cleanly separated by project
- Cross-project queries work
- No dependency conflicts

**Learnings to Capture:**
- What works well?
- What's confusing?
- What's missing?
- What breaks?

---

### Phase 4: Refinement & Documentation (Week 5-6)

**Goal:** Make it usable for next 6 months

**Tasks:**
1. ⚠️ Document complete workflow
   - Setup new project guide
   - Task file format reference
   - Query examples
   - Troubleshooting FAQ
2. ⚠️ Add convenience features
   - `just new-project <name>` - Scaffold with `.ai-team/`
   - `just task <project> <description>` - Create task from CLI
   - `just tail` - Watch AI-team logs in real-time
3. ⚠️ Improve observability
   - Better error messages
   - Progress indicators
   - Notification when task completes (optional)
4. ⚠️ Backup strategy
   - time-lab → Git LFS or separate repo
   - Retention policy for old artifacts
   - Export/import for sharing

**Success Criteria:**
- Can onboard new project in < 5 minutes
- Documentation answers common questions
- System feels stable and predictable
- Ready to use for 6 months without major changes

**Deliverables:**
- Comprehensive README
- Setup guide
- Task format reference
- Example tasks for common patterns

---

## 🎯 Success Metrics: How We Know It's Working

### Quantitative (Easy to Measure)

1. **Time Saved**
   - Before: X minutes to context switch + repeat LLM workflow
   - After: Drop task file, continue working
   - Target: 30% reduction in context switching cost

2. **Projects Maintained**
   - Before: Focus on 1-2 projects at a time
   - After: Can advance 3-5 projects simultaneously
   - Target: 2x increase in concurrent project progress

3. **Insights Captured**
   - Before: Insights lost or in disparate notes
   - After: Queryable artifact history
   - Target: 50+ artifacts in first 3 months

### Qualitative (Harder to Measure, More Important)

1. **Feels Like Leverage**
   - AI-team genuinely helps, doesn't add overhead
   - Query history actually provides value
   - System encourages experimentation (low cost to try)

2. **Reduces Friction**
   - Starting new project is easy (scaffold + AI assistance)
   - Resuming old project is easy (query history, continue)
   - Environment issues are rare (Nix reproducibility)

3. **Compounds Learning**
   - Patterns emerge from cross-project queries
   - Failures are documented and searchable
   - "What did we try before?" is answerable

### Red Flags (When to Reconsider)

- ⚠️ Spending more time maintaining system than building projects
- ⚠️ Artifacts accumulate but never queried (dead weight)
- ⚠️ AI-team daemon is flaky, requires constant restart
- ⚠️ Nix builds become slower than system installs
- ⚠️ System feels like obligation, not advantage

**If 2+ red flags persist after Phase 4, reassess architecture.**

---

## 🧭 Guiding Principles

### 1. Principle of Least Action
Build the minimum that works, expand when needed.

**Examples:**
- Start with 1 project, add more when proven
- Start with manual queries, add indexing when slow
- Start with local LLAMA, add API fallback if needed

### 2. Separation Enables Composition
Keep layers independent so they can evolve separately.

**Examples:**
- AI-team can be replaced without touching time-lab
- Time-lab can store artifacts from other tools (not just AI-team)
- Projects can use AI-team without time-lab (just keep local logs)

### 3. Nix for Reproducibility, Not Purity
Use Nix where it helps, not everywhere dogmatically.

**Examples:**
- Project flakes: Yes (environment reproducibility critical)
- System tools: No (don't Nix-ify everything, use system packages when fine)
- Secrets: No (use .env files, not Nix store)

### 4. Optimize for Learning, Not Perfection
This is an experiment to gain advantage, not a product to ship.

**Examples:**
- Document failures (they're data)
- Keep artifacts even if AI made mistakes
- Query history to find patterns (what works, what doesn't)

### 5. Build for Present Needs, Design for Future Growth
Solve today's problems with tomorrow's scalability in mind.

**Examples:**
- 3-layer architecture supports growth without refactor
- Protocol-based communication allows swapping components
- Date organization scales from dozens to thousands of artifacts

---

## 🎨 Philosophy: Why This Approach Works

### It Matches Your Reality

You're not Google (thousands of engineers, infinite resources).
You're not a hobbyist (just tinkering, no real goals).

**You're a builder learning by doing, managing multiple projects, creating leverage.**

This system is designed for that reality:
- **Solo dev** - No team coordination overhead
- **Multiple projects** - Architecture supports polyglot, independent repos
- **Learning focus** - Captures experiments, not just successes
- **Leverage seeking** - Compounds effort across projects

### It Respects Constraints

1. **Time** - You can't spend months building tools
   - Phased approach (6 weeks to working system)
   - Each phase delivers value (not all-or-nothing)

2. **Experience** - Less than 1 year coding
   - Uses familiar tools (Python, JSON, shell scripts)
   - Nix for benefits, not complexity
   - Can ask AI for help (meta: use AI to build AI system)

3. **Resources** - Running locally, not cloud services
   - Local LLAMA (privacy + cost)
   - File-system storage (simple, debuggable)
   - Nix (reproducible without Docker/K8s complexity)

### It Builds on Existing Work

- ✅ AI-team already exists (Windows-proven)
- ✅ time-lab foundation laid (flake, schemas, scripts)
- ✅ Task manager experience (you've done this before)
- ✅ Projects waiting to benefit (auth, crypto, discord, etc.)

**Not starting from zero. Connecting existing pieces.**

---

## 🚀 Getting Started: Immediate Next Steps

### This Week (Phase 0)

1. **Test AI-team on Linux**
   ```bash
   cd ~/AI-team
   # Edit settings.py: remove C:\ hardcoded path
   # Add to .env: CLAUDE_BASE_CWD=/home/gorila/projects
   nix develop  # or setup Python venv
   python src/orchestrator.py --help
   ```

2. **Create test project**
   ```bash
   cd ~/projects
   mkdir test-project
   cd test-project
   mkdir -p .ai-team/tasks
   echo "---
   id: test_001
   type: analyze
   ---
   # Test Task

   Analyze this project structure." > .ai-team/tasks/test.task.md
   ```

3. **Run AI-team daemon**
   ```bash
   cd ~/AI-team
   python src/orchestrator.py daemon --watch ~/projects
   # Watch logs, verify it detects the test task
   ```

4. **Verify execution**
   ```bash
   # Check AI-team/results/ for output
   # Check AI-team/logs/events.ndjson for events
   ```

**Goal:** Prove AI-team works on Linux before integrating with time-lab.

---

## 📖 Related Documents

- `docs/0-start/GETTING_STARTED.md` - User onboarding
- `docs/2-use/WORKFLOW.md` - Daily operations
- `docs/3-extend/EXTENSION_GUIDE.md` - Adding features
- `docs/reference/ARCHITECTURE.md` - System design
- `docs/reference/DECISIONS.md` - Why we made choices
- `docs/context/COMPARISON_TO_TIME_2025.md` - Learning from inspiration

---

## 🤔 Open Questions (To Revisit After Phase 2)

1. **Artifact Retention**
   - Keep all artifacts forever? Or prune after N months?
   - How to handle large binary artifacts (videos, datasets)?

2. **Cross-Project Insights**
   - Manual querying enough? Or build dashboard?
   - LLM-powered analysis of patterns?

3. **Sharing**
   - Keep private? Or publish sanitized version?
   - Can colleague use my AI-team with their time-lab?

4. **GitHub Integration**
   - Poll for PRs/CI failures (Phase 5)?
   - Webhook-driven (more complex, but faster)?

5. **Other Tools**
   - Should non-AI tools write to time-lab?
   - Manual experiments, refactorings, migrations?

**Don't answer now. Build first, learn, then decide.**

---

## ✅ Commitment: What Success Looks Like

**3 Months from Now:**

I can:
- Drop a task file in any project and get AI assistance
- Query "what login work have I done?" and get answers
- Resume old projects without losing context
- Maintain 3-5 projects simultaneously without burnout

I have:
- 50+ artifacts in time-lab documenting real work
- Patterns emerging from cross-project analysis
- Confidence in reproducibility (Nix works reliably)
- Reduced context switching cost (measurable time savings)

I've learned:
- Nix deeply (forced by building this)
- System design (separating concerns, protocols)
- What LLM automation actually helps with (vs hype)

**If this happens, the system succeeded.**

---

## 🎯 Final Word: Why This Matters

This isn't about building the "next big thing."
This isn't about perfection or best practices.
This isn't about impressing anyone.

**This is about:**
- Creating advantage for yourself as a builder
- Learning systems thinking by building a system
- Experimenting safely (reproducibility = low cost to fail)
- Compounding effort across projects

You started coding less than a year ago.
You're managing multiple complex projects.
You're learning Nix, Python, Rust, Android, crypto, LLMs.

**This system gives you an unfair advantage by making AI help you consistently.**

Not magic. Not hype. Just leverage.

---

**Now let's build Phase 0.**
