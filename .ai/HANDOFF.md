# Session Handoff Protocol

How to transfer work between sessions and agents.

---

## Starting a New Session

### First Session (Fresh Start)
```
I want to build this project.

Read .ai/ folder:
1. CONTEXT.md - current state
2. RULES.md - execution contract
3. GUIDE.md - build reference

Then begin from the current phase in CONTEXT.md.
```

### Continuing Session (Previous Work Exists)
```
Continue work on this repo.

Read .ai/CONTEXT.md for current state, then proceed from the next incomplete task.
```

### Context Lost Mid-Session
```
Re-read .ai/CONTEXT.md and continue from the Active tasks section.
```

---

## Ending a Session

### Standard Procedure

1. **Update CONTEXT.md**:
   - Mark completed tasks with `[x]`
   - Update "Active" section with current task
   - Add any blockers to "Blockers" section
   - Add notes to "Notes" section if needed
   - Update "Last Updated" timestamp
   - Update "Updated By" with your model name

2. **Commit Changes**:
   ```bash
   git add .
   git commit -m "type(scope): what was done

   - Detail 1
   - Detail 2

   Phase X progress"
   ```

3. **Inform User**:
   - Summarize what was completed
   - State what's next
   - Mention any blockers
   - Confirm context was updated

### Example Update

**Before**:
```markdown
## Active
- [ ] Phase 1: Foundation
  - [ ] flake.nix created
  - [ ] .gitignore created
```

**After**:
```markdown
## Completed
- [x] Phase 0: Prerequisites

## Active
- [ ] Phase 1: Foundation
  - [x] flake.nix created
  - [x] .gitignore created
  - [ ] Justfile pending
```

---

## Multi-Agent Handoff

### When Switching LLMs

**Outgoing Agent** (end of session):
1. Complete current task if possible
2. Update CONTEXT.md thoroughly
3. Note any partial work in "Notes"
4. Commit with clear message

**Incoming Agent** (start of session):
1. Read CONTEXT.md completely
2. Read RULES.md for contract
3. Check GUIDE.md for phase reference
4. Update "Updated By" in CONTEXT.md
5. Continue from last incomplete task

### Handoff Message Template

**User to New Agent**:
```
A previous agent was working on this repo.

Read .ai/CONTEXT.md to see current progress, then continue from where they left off.
Follow .ai/RULES.md for execution standards.
```

---

## Recovery Procedures

### Context Corruption

If CONTEXT.md is unclear:

1. **Check Git History**:
   ```bash
   git log --oneline .ai/CONTEXT.md
   ```

2. **Review Recent Commits**:
   ```bash
   git log --oneline -10
   ```

3. **Reconstruct State**:
   - List completed files: `ls -la`
   - Check what exists vs guide
   - Update CONTEXT.md with current state

4. **Ask User**:
   ```
   CONTEXT.md seems unclear. Based on git history, it appears Phase X is complete.
   Should I continue with Phase Y?
   ```

### Conflicting Information

If CONTEXT.md conflicts with actual state:

1. **Verify Actual State**:
   ```bash
   # Check what exists
   ls -la scripts/
   nix develop --command which just
   ```

2. **Update CONTEXT.md** to match reality

3. **Document in Notes**:
   ```markdown
   ## Notes
   - Corrected CONTEXT.md to reflect actual state
   - Phase 2 scripts exist but weren't marked complete
   ```

### Missing Dependencies

If you discover missing prerequisites:

1. **Document in Blockers**:
   ```markdown
   ## Blockers
   - Nix not installed (required for Phase 1)
   - Awaiting user to install
   ```

2. **Stop and Inform User**:
   ```
   Blocker: Nix is not installed. 
   Please install Nix with flakes, then I can continue with Phase 1.
   Installation: https://nixos.org/download.html
   ```

3. **Update CONTEXT.md**

4. **Commit**:
   ```bash
   git commit -m "chore: document blocker - Nix installation required"
   ```

---

## Progress Tracking

### Phase Completion

When marking a phase complete:

```markdown
## Completed
- [x] Phase 0: Prerequisites
- [x] Phase 1: Foundation  <-- Just completed

## Active
- [ ] Phase 2: Core Scripts  <-- Now active
```

**Also**:
- Run tests for that phase
- Verify functionality works
- Commit with phase number in message

### Task Granularity

Break phases into checkboxes:

```markdown
- [ ] Phase 2: Core Scripts
  - [x] today.sh created and tested
  - [x] run_llm_task.sh created
  - [ ] mine_commits.sh (placeholder)
  - [ ] summarize_diff.sh (placeholder)
  - [ ] sync_latest.sh created
```

This helps track partial progress.

---

## Communication Protocol

### Status Updates

After each significant task:
```
✅ Completed: Created flake.nix with default devShell
📝 Updated: .ai/CONTEXT.md
🔄 Next: Create .gitignore and .gitattributes
```

### Asking for Approval

Before destructive operations:
```
⚠️ About to run: nix-collect-garbage --delete-older-than 7d
This will delete Nix store entries older than 7 days.
Proceed? (y/n)
```

### Reporting Blockers

When stuck:
```
🚫 Blocker Encountered:
- What: Nix build failed with error XYZ
- Phase: 3 (Rust Tools)
- Attempted: cargo build, nix build
- Need: Clarification on Cargo.lock handling

Updated .ai/CONTEXT.md with blocker.
```

---

## Best Practices

### Commit Frequency
- After each completed task (not sub-task)
- Before ending session
- When switching focus areas
- After fixing bugs

### Context Updates
- After completing any checklist item
- When discovering new information
- When hitting blockers
- At session end (always)

### Clarity
- Be specific in CONTEXT.md notes
- Link to commits when relevant
- Document decisions made
- Explain non-obvious choices

---

## Example Full Handoff

**Session 1 End** (Agent A):
```markdown
## Completed
- [x] Phase 0: Prerequisites
- [x] Phase 1: Foundation

## Active
- [ ] Phase 2: Core Scripts
  - [x] today.sh created and tested
  - [x] run_llm_task.sh created
  - [ ] Remaining scripts pending

## Next
Complete remaining Phase 2 scripts.

## Notes
- Using WSL2 environment
- Nix 2.18.1 confirmed working
- just day creates proper structure

**Last Updated**: 2025-10-15 16:00 UTC
**Updated By**: Claude Sonnet 3.5
```

**Session 2 Start** (Agent B):
```
Read .ai/CONTEXT.md - I see Phase 2 is in progress.
I'll continue with the remaining scripts (mine_commits.sh, summarize_diff.sh, sync_latest.sh).
```

---

**Remember**: CONTEXT.md is the source of truth. Keep it updated, and handoffs will be smooth.

