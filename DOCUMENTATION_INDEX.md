# Documentation Index

Navigate Time-Lab documentation by purpose and reading order.

---

## 📂 Documentation Structure

```
docs/
├── 0-start/           👋 First time? Start here
│   └── GETTING_STARTED.md
├── 2-use/             🚀 Daily operations
│   └── WORKFLOW.md
├── 3-extend/          🔧 Adding features
│   └── EXTENSION_GUIDE.md
├── reference/         📖 Look things up
│   ├── GLOSSARY.md
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   └── schemas/
├── context/           🎓 Background
│   └── COMPARISON_TO_TIME_2025.md
└── archive/           📦 Completed phases
    └── 1-build-completed-2025-10-16/
        ├── IMPLEMENTATION_GUIDE.md
        └── BUILD_COMPLETE.md
```

---

## 📖 Document Guide

### 0️⃣ Getting Started

#### **[GETTING_STARTED.md](docs/0-start/GETTING_STARTED.md)**
**Purpose**: Complete onboarding in 30 minutes

**Contents**:
- Prerequisites and installation
- Quick setup (3 commands)
- Your first experiment (hands-on)
- Key concepts explained
- Next experiments to try
- Troubleshooting

**Use When**: First time using Time-Lab

**Time**: 30 minutes

---

### 📦 Build Archive (Completed 2025-10-16)

#### **[IMPLEMENTATION_GUIDE.md](docs/archive/1-build-completed-2025-10-16/IMPLEMENTATION_GUIDE.md)** ✅
**Status**: Build complete - Archived for reference

**Contents** (8 Phases - All Complete):
- ✅ Phase 0: Prerequisites and Nix setup
- ✅ Phase 1: Foundation (flake.nix, .gitignore, Justfile)
- ✅ Phase 2: Core Scripts (today.sh, run_llm_task.sh)
- ✅ Phase 3: Rust Tools (rust_extractor)
- ✅ Phase 4: Python Tools (py_post)
- ✅ Phase 5: Quality & Safety (pre-commit, shellcheck)
- ✅ Phase 6: Documentation & Schemas
- ✅ Phase 7: CI/CD (GitHub Actions)
- ✅ Phase 8: Validation (integration tests)

**Build Summary**: See [BUILD_COMPLETE.md](docs/archive/1-build-completed-2025-10-16/BUILD_COMPLETE.md)

**Use When**:
- Understanding how the system was built
- Rebuilding in a new environment
- Historical reference

**Time**: Reference only (build already complete)

---

### 2️⃣ Daily Use

#### **[WORKFLOW.md](docs/2-use/WORKFLOW.md)**
**Purpose**: Day-to-day development operations

**Contents**:
- Daily routine (start → work → commit → push)
- Coding standards by language (Nix, Shell, Rust, Python)
- Testing practices
- Version control (commit messages, branches)
- Common tasks (update deps, add packages)
- Troubleshooting

**Use When**: Daily development work, code reviews

**Time**: Reference as needed

---

### 3️⃣ Extending

#### **[EXTENSION_GUIDE.md](docs/3-extend/EXTENSION_GUIDE.md)**
**Purpose**: Add new features and integrations

**Contents**:
- Extension points overview
- Adding new task types (full compile example)
- Adding new tools (CSV analyzer example)
- Adding DevShell profiles (data science example)
- External integrations (GitHub API example)
- Extension contracts (inputs, outputs, exit codes)
- Plugin system (future)

**Use When**:
- Adding new functionality
- Integrating external services
- Creating custom tools

**Time**: 30 min per extension (with examples)

---

### 📚 Reference

#### **[GLOSSARY.md](docs/reference/GLOSSARY.md)**
**Purpose**: Canonical term definitions

**Contents**:
- 50+ core terms defined
- Core concepts (Artifact, Manifest, Run, Spec, Task)
- Technical terms (Deterministic Build, Provenance)
- Workflow terms (Daily Tree, Latest Symlink)
- Directory structure terms
- File types and status values
- Anti-patterns (what NOT to call things)
- Term relationships (visual diagrams)

**Use When**:
- Unclear on what a term means
- Writing documentation
- Onboarding new contributors
- Resolving terminology debates

**Time**: Lookup as needed

---

#### **[ARCHITECTURE.md](docs/reference/ARCHITECTURE.md)**
**Purpose**: System design and patterns

**Contents**:
- System overview and philosophy
- Core principles (determinism, traceability, isolation, safety)
- Component architecture with diagrams
- Data flow for common workflows
- Reproducibility model (run IDs, environment pinning)
- Performance and security considerations

**Use When**:
- Understanding design decisions
- Planning new features
- Reviewing architecture
- Debugging complex issues

**Time**: 20-30 min read

---

#### **[DECISIONS.md](docs/reference/DECISIONS.md)**
**Purpose**: Architectural Decision Records (ADRs)

**Contents** (12 decisions):
- D001: VM on Windows, no Docker
- D002: Single monorepo
- D003: Date tree YYYY/MM/DD
- D004: Run manifests must follow schema
- D005: Model calls logged with params + seed
- D006: DevShells instead of full nixification
- D007: UTC timestamps everywhere
- D008: Secrets outside git (SOPS or .env)
- D009: Shell scripts with strict mode
- D010: Network offline by default (proposed)
- D011: Pre-commit hooks for quality
- D012: Justfile for task running

**Use When**:
- Questioning a design choice
- Proposing changes
- Understanding tradeoffs
- Recording new decisions

**Time**: Lookup specific decisions

---

#### **[schemas/](docs/reference/schemas/)**
**Purpose**: JSON Schema definitions for validation

**Files**:
- `run.schema.json` - Run manifest validation
- `spec.schema.json` - Base spec validation
- `llm_task.schema.json` - LLM task specs
- `mining_task.schema.json` - Git mining specs
- `README.md` - Usage guide and examples

**Use When**:
- Validating specs before execution
- Creating new specs (IDE autocomplete)
- Extending with new task types
- Ensuring data quality

**Time**: Reference as needed

---

### 🎓 Context

#### **[COMPARISON_TO_TIME_2025.md](docs/context/COMPARISON_TO_TIME_2025.md)**
**Purpose**: Learning from the original repo

**Contents**:
- 8 key lessons learned from time-2025
- Pattern mapping (what became what)
- Key differences (simplified vs added)
- Migration path for existing repos
- What to keep/adapt/avoid
- Evolution roadmap

**Use When**:
- Understanding why certain patterns exist
- Learning from the original repo
- Migrating existing work
- Explaining project philosophy

**Time**: 15-20 min read

---

## 🎯 Reading Paths

### For Different Personas

#### 👤 New Developer
```
1. docs/0-start/GETTING_STARTED.md (30 min)
2. docs/reference/GLOSSARY.md (as needed)
3. docs/2-use/WORKFLOW.md (reference)
```

#### 🏗️ Implementer (Building Time-Lab) - ✅ Build Complete
```
Build completed 2025-10-16. For reference:
1. docs/archive/1-build-completed-2025-10-16/BUILD_COMPLETE.md
2. docs/archive/1-build-completed-2025-10-16/IMPLEMENTATION_GUIDE.md
```

#### 🔍 Researcher (Understanding Patterns)
```
1. docs/context/COMPARISON_TO_TIME_2025.md (context)
2. docs/reference/ARCHITECTURE.md (design)
3. docs/reference/DECISIONS.md (rationale)
4. docs/reference/GLOSSARY.md (terminology)
```

#### 🧑‍💼 Project Lead
```
1. README.md (overview)
2. docs/reference/ARCHITECTURE.md (design)
3. docs/reference/DECISIONS.md (governance)
```

#### 🔧 Extender
```
1. docs/3-extend/EXTENSION_GUIDE.md (how to extend)
2. docs/reference/schemas/ (validation)
3. docs/reference/GLOSSARY.md (terms)
```

---

## 📊 Documentation Metrics

| Document | Lines | Size | Status | Purpose |
|----------|-------|------|--------|---------|
| GETTING_STARTED.md | ~200 | 5.8KB | Active | Onboarding |
| IMPLEMENTATION_GUIDE.md | 1,543 | 34KB | ✅ Archived | Build guide |
| WORKFLOW.md | ~100 | 2.9KB | Active | Daily ops |
| EXTENSION_GUIDE.md | 886 | 20KB | Active | Extensions |
| GLOSSARY.md | 558 | 13KB | Active | Terms |
| ARCHITECTURE.md | ~400 | 15KB | Active | Design |
| DECISIONS.md | 365 | 11KB | Active | ADRs |
| COMPARISON_TO_TIME_2025.md | 392 | 10KB | Active | Context |
| BUILD_COMPLETE.md | ~100 | 3KB | ✅ Archived | Summary |
| **Total** | **~4,600** | **~115KB** | Complete |

---

## 🗂️ Folder Organization

The numbered folders indicate **workflow progression**:

- **0-start/** - Begin here (onboarding)
- **2-use/** - Daily operations (active development)
- **3-extend/** - Add features (when needed)
- **reference/** - Look up anytime (always relevant)
- **context/** - Background info (optional)
- **archive/** - Completed phases (historical reference)

**Note**: ~~1-build/~~ has been archived (build complete 2025-10-16)

**Self-navigating**: Folder names tell you their purpose and state.

---

## ✅ What's Covered

| Topic | Documentation |
|-------|---------------|
| Installation | GETTING_STARTED.md |
| First experiment | GETTING_STARTED.md |
| Building from scratch | IMPLEMENTATION_GUIDE.md |
| Daily development | WORKFLOW.md |
| Extending | EXTENSION_GUIDE.md |
| Term definitions | GLOSSARY.md |
| System design | ARCHITECTURE.md |
| Design decisions | DECISIONS.md |
| Validation | schemas/ |
| Historical context | COMPARISON_TO_TIME_2025.md |

---

## 🚀 Quick Start Paths

### Build Already Complete ✅
```
Build finished 2025-10-16. See:
1. docs/archive/1-build-completed-2025-10-16/BUILD_COMPLETE.md
   → Summary of what was built
2. docs/0-start/GETTING_STARTED.md
   → Start using the system
```

### Just Want to Learn?
```
1. docs/0-start/GETTING_STARTED.md (30 min)
   → Hands-on tutorial
```

### Just Want to Extend?
```
1. docs/3-extend/EXTENSION_GUIDE.md
   → Copy working examples
```

### Just Need Reference?
```
docs/reference/
├── GLOSSARY.md (terms)
├── ARCHITECTURE.md (design)
├── DECISIONS.md (why)
└── schemas/ (validation)
```

---

## 💡 Tips

**Overwhelmed?**
- Start with `docs/0-start/GETTING_STARTED.md`
- Ignore everything else until you need it

**Building?**
- Follow `docs/1-build/IMPLEMENTATION_GUIDE.md` phase by phase
- Reference docs only when stuck

**Daily work?**
- Bookmark `docs/2-use/WORKFLOW.md`
- Check `docs/reference/GLOSSARY.md` for terms

**Extending?**
- `docs/3-extend/EXTENSION_GUIDE.md` has working code examples
- Copy, modify, done

---

**Created**: 2025-10-15
**Status**: ✅ Active
**Last Updated**: 2025-10-16 (Build phase archived)
