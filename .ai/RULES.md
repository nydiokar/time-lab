# Agent Rules

Universal contract for AI agents working on this repository.

!! DO NOT MODIFY UNLESS PROMPTED TO !!

---

## 1. Context Management

- **Read** `.ai/CONTEXT.md` at session start
- **Update** `.ai/CONTEXT.md` after completing each task
- **Never modify** `.ai/RULES.md` or `.ai/GUIDE.md` (immutable contract)
- **Commit** context updates with meaningful messages

---

## 2. Execution Protocol

### Sequential Execution
- Execute **one phase completely** before moving to next
- Complete all tasks in a phase before marking it done
- Don't skip steps or phases

### Validation
- Validate files against schemas in `docs/reference/schemas/`
- Run `just check` before committing code changes
- Test each component after creation

### Approval Required
- **Ask before** running destructive commands:
  - `rm -rf`, `git reset --hard`, `git push --force`
  - `nix-collect-garbage`, system-wide installs
  - Modifying `.git/` or `.gitignore`
- **Ask before** making architectural changes not in guide
- **Proceed without asking** for standard build steps

---

## 3. Code Quality

### Follow Standards
- **Nix**: Format with `alejandra`
- **Shell**: Use `set -Eeuo pipefail`, pass `shellcheck`
- **Rust**: Use `cargo fmt`, `cargo clippy`
- **Python**: Use `black`, `ruff`, `mypy`, Pydantic models
- **All**: Strict types, functional over OOP, no hidden mutations

### Testing
- Test after each phase completion
- Run integration tests before marking phase complete
- Document any test failures in `.ai/CONTEXT.md`

---

## 4. Documentation

### Reference Material
- **Terms**: `docs/reference/GLOSSARY.md` - use these exact definitions
- **Patterns**: Follow examples in IMPLEMENTATION_GUIDE.md exactly
- **Don't invent**: Use established patterns, don't improvise
- **Update context**: Document decisions in `.ai/CONTEXT.md`

### Communication
- Use canonical terms from GLOSSARY.md
- Be specific: "manifest" not "config", "spec" not "input file"
- Cite documentation: "Per IMPLEMENTATION_GUIDE Phase 2..."

---

## 5. Error Handling

### When Stuck
1. Re-read current phase in IMPLEMENTATION_GUIDE.md
2. Check GLOSSARY.md for term clarification
3. Review CONTEXT.md for what was already done
4. Ask user for clarification (don't guess)

### Exit Codes
Use standard exit codes in scripts:
- `0` - Success
- `64` - Usage error (missing/invalid arguments)
- `65` - Data error (invalid input file)
- `70` - Internal error (unexpected failure)

---

## 6. Session Handoff

### Before Ending Session
1. Update `.ai/CONTEXT.md` with:
   - What was completed (mark checkboxes)
   - Current phase and next task
   - Any blockers or issues
   - "Last Updated" timestamp
   - "Updated By" (your model name)
2. Commit work with clear message
3. Push changes (if appropriate)

### Starting New Session
1. Read `.ai/CONTEXT.md` first
2. Read `.ai/RULES.md` (this file)
3. Check `.ai/GUIDE.md` for current phase reference
4. Continue from last incomplete task in CONTEXT.md

---

## 7. Scope Boundaries

### In Scope
- Following IMPLEMENTATION_GUIDE.md phases
- Building components as specified
- Standard troubleshooting and debugging
- Updating CONTEXT.md with progress

### Out of Scope
- Adding features not in the guide
- Changing architecture without approval
- Skipping validation steps "to save time"
- Modifying the guide itself

---

## 8. Version Control

### Commit Messages
Use conventional commits:
```
<type>(<scope>): <subject>

<body>
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```
feat(nix): add flake.nix with default devShell

- Define buildInputs with core tools
- Add shellHook for environment message
- Pin nixpkgs to unstable

Phase 1 of IMPLEMENTATION_GUIDE.md
```

### Branch Strategy
- `main` - Stable
- Work directly on main for initial build (single developer)
- Create branches for experiments later

---

## 9. File Operations

### Create
- Use exact paths from IMPLEMENTATION_GUIDE.md
- Set correct permissions (`chmod +x` for scripts)
- Validate syntax before committing

### Modify
- Make minimal changes (principle of least action)
- Preserve existing structure and formatting
- Document why change was needed

### Delete
- **Only with approval** - never delete files without asking
- Prefer renaming/moving over deletion
- Update references in other files

---

## 10. Special Cases

### Windows/WSL2
- Commands may need adjustment for PowerShell vs Bash
- Note OS differences in CONTEXT.md
- Test scripts work in target environment

### Missing Dependencies
- Document in CONTEXT.md as blocker
- Suggest installation method
- Wait for user to install (don't assume `sudo`)

### Ambiguity
- **Ask, don't guess**
- Reference specific documentation
- Propose options with pros/cons

---

## Summary

**Golden Rule**: Follow the guide exactly, validate everything, update context frequently, ask when uncertain.

**Commit Often**: Small, tested, documented commits.

**Stay Focused**: One phase at a time, one task at a time.

