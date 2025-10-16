# Work Guide

Reference for what to build/fix/improve.

---

## Project Goal

[One sentence: What is this project trying to achieve?]

---

## Main Documentation

[List primary documentation sources]

**If no docs exist**:
- Explore codebase in `src/` or similar
- Read `README.md` for overview
- Check for `CONTRIBUTING.md` or `DEVELOPMENT.md`
- Look for inline comments
- Ask user for context

---

## Task List

[Ordered list of what needs to be done]

### Example Structure

1. **Setup**
   - [ ] Task 1
   - [ ] Task 2

2. **Implementation**
   - [ ] Feature A
   - [ ] Feature B

3. **Testing**
   - [ ] Unit tests
   - [ ] Integration tests

4. **Documentation**
   - [ ] Update README
   - [ ] Add examples

---

## Key Files

[Important files and what they do]

**Example**:
- `src/main.py` - Entry point
- `config.json` - Configuration
- `tests/` - Test suite
- `docs/` - Documentation

---

## Build/Run Commands

[How to build and run the project]

**Example**:
```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm test

# Build for production
npm run build
```

---

## Testing Strategy

[How to verify changes work]

**Example**:
- Run unit tests: `npm test`
- Manual testing: `npm run dev` and test feature
- Integration tests: `npm run test:integration`

---

## Reference Material

[Where to find information when stuck]

**Common locations**:
- `README.md` - Project overview
- `CONTRIBUTING.md` - Development guidelines
- `docs/` - Detailed documentation
- Code comments - Inline explanations
- Git history - Past decisions

**If minimal docs**:
- Read existing code for patterns
- Look for similar features
- Check dependencies' documentation
- Ask user for clarification

---

## Success Criteria

[How to know when done]

**Example**:
- [ ] All tasks completed
- [ ] Tests passing
- [ ] Documentation updated
- [ ] No linter errors
- [ ] Code reviewed (if applicable)

---

## Common Patterns

[Recurring patterns in this codebase]

**Example**:
```python
# Standard function structure
def process_data(input: dict) -> dict:
    """Process input data."""
    # Validate
    if not input:
        raise ValueError("Input required")

    # Process
    result = transform(input)

    # Return
    return result
```

---

## Troubleshooting

[Common issues and solutions]

**Example**:
- **Import errors**: Run `pip install -r requirements.txt`
- **Build fails**: Clear cache with `rm -rf node_modules && npm install`
- **Tests fail**: Check if dependencies are up to date

---

**Remember**: Follow existing patterns. Keep changes focused. Test everything.
