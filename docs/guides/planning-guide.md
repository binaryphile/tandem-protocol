# Planning Guide

**Stage:** Plan (P)
**Focus:** Design approach - "How should we do this?"

## Lessons

### Simplicity: Consider simpler alternatives before complex ones
**Context:** When designing solution approach
**Lesson:** Evaluate at least one simpler alternative before committing to complex solution
**Source:** UC9 seed

### Criteria: Define success criteria before implementation
**Context:** When finalizing plan for user approval
**Lesson:** Specify measurable criteria that determine when work is complete
**Source:** UC9 seed

### Risks: Identify risks and mitigations upfront
**Context:** When approach has dependencies or unknowns
**Lesson:** List risks with mitigation strategies; don't defer risk identification to implementation
**Source:** UC9 seed

### Value Proposition First: Lead with benefits
**Context:** When structuring documentation or presentations
**Lesson:** Lead with problem/solution and benefits. Move detailed mechanics to supporting documents.
**Source:** README restructure session - 259 → 114 lines by leading with value

## Usage Example

Subagent returns structured output referencing lessons:

```markdown
### Lessons Applied
- "Criteria: Define success criteria before implementation": Specified 4 measurable criteria
- "Value Proposition First: Lead with benefits": README opens with Why/What You Get, details in FEATURES.md

### Lessons Missed
- "Simplicity: Consider simpler alternatives before complex ones": Jumped to complex solution without evaluating alternatives
```
