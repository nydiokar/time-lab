# .ai Template

Universal AI agent contract that works with any project.

## Quick Start

### Option 1: Copy Manually

```bash
# Copy template to your project
cp -r .ai-template/ /path/to/your-project/.ai/

# Customize
cd /path/to/your-project
edit .ai/CONTEXT.md  # Set project name, goal, etc.
edit .ai/GUIDE.md    # Add your tasks
```

### Option 2: Use Init Script

```bash
# From this repo
./ai-template/init-ai.sh "My Project" "Build awesome software"

# Or copy script to project first
cp .ai-template/init-ai.sh /path/to/your-project/
cd /path/to/your-project
./init-ai.sh "Project Name" "Main Goal"
```

## What You Get

```
.ai/
├── CONTEXT.md   # Current state (AI updates this)
├── RULES.md     # Execution contract (immutable)
├── GUIDE.md     # What to build (reference)
└── HANDOFF.md   # Session transfer protocol
```

## Usage

Tell any LLM:
```
Read .ai/ folder for context and rules, then begin work as outlined in GUIDE.md.
```

Works with:
- ✅ Claude (Anthropic)
- ✅ GPT-4 (OpenAI)
- ✅ Cursor
- ✅ Aider
- ✅ Continue
- ✅ Any LLM with file access

## Customization

### For Well-Documented Projects

If project has:
- README.md
- CONTRIBUTING.md
- Architecture docs
- Test suite

**Update GUIDE.md** to reference them:
```markdown
## Main Documentation
- README.md - Project overview
- docs/ARCHITECTURE.md - System design
- CONTRIBUTING.md - Development workflow
```

### For Minimal Projects

If project lacks documentation:

**GUIDE.md becomes the guide**:
```markdown
## Main Documentation
None exists. Explore codebase:
- src/ - Main source code
- tests/ - Test suite
- Read code comments

## Task List
1. Add feature X
2. Fix bug Y
3. Write tests
```

## File Roles

### CONTEXT.md (Mutable)
- **Who updates**: AI agent after each task
- **What it tracks**: Current progress, blockers, notes
- **Format**: Markdown with checkboxes

### RULES.md (Immutable)
- **Who updates**: Humans only (rarely)
- **What it defines**: Execution contract, standards
- **Format**: Numbered rules

### GUIDE.md (Reference)
- **Who updates**: Humans (as project evolves)
- **What it contains**: Task list, patterns, reference
- **Format**: Structured markdown

### HANDOFF.md (Protocol)
- **Who updates**: Rarely
- **What it defines**: Session transfer process
- **Format**: Step-by-step procedures

## Benefits

**Universal**: Works with any LLM, any project
**Lightweight**: ~5KB total
**Self-updating**: AI keeps CONTEXT.md current
**Portable**: Copy to any project
**Simple**: 4 files, clear roles

## Examples

### Minimal Setup (No Docs)
```markdown
# .ai/GUIDE.md
## Goal
Fix authentication bug in login flow

## Tasks
- [ ] Reproduce bug locally
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Add test
- [ ] Verify fix works

## Reference
- src/auth.py - Authentication logic
- tests/test_auth.py - Auth tests
```

### Full Setup (With Docs)
```markdown
# .ai/GUIDE.md
## Main Documentation
Follow docs/BUILD.md phases 1-5

## Reference
- docs/ARCHITECTURE.md - System design
- docs/GLOSSARY.md - Term definitions
- docs/API.md - API reference

## Tasks
See BUILD.md for complete task list
```

## Integration with Time-Lab

This template was derived from Time-Lab's `.ai/` folder.

Time-Lab has additional docs:
- GLOSSARY.md (50+ terms)
- IMPLEMENTATION_GUIDE.md (8 phases)
- JSON schemas for validation

Other projects won't have these, so template is **minimal and generic**.

## Contributing

Improvements to template:
1. Keep it generic (works anywhere)
2. Keep it small (<10KB total)
3. Keep it universal (any LLM)
4. Test with different project types

## License

Public domain. Use anywhere.
