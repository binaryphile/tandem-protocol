# Investigation Guide

**Stage:** Investigate (I)
**Focus:** Explore context - "What exists?"

## Lessons

### Patterns: Check for existing patterns first
**Context:** Before proposing new error handling, logging, or architectural patterns
**Lesson:** Search codebase for existing patterns before designing new ones
**Source:** UC9 seed

### Dependencies: Verify dependencies early
**Context:** When planning changes that may affect or require other modules
**Lesson:** Identify upstream/downstream dependencies before committing to approach
**Source:** UC9 seed

### Boundaries: Map the boundaries
**Context:** When entering unfamiliar code area
**Lesson:** Identify package boundaries and ownership before diving into implementation details
**Source:** UC9 seed

## Usage Example

Subagent returns structured output referencing lessons:

```markdown
### Lessons Applied
- "Patterns: Check for existing patterns first": Found error handling in pkg/errors before proposing new pattern

### Lessons Missed
- "Dependencies: Verify dependencies early": Did not check downstream consumers until implementation
```
