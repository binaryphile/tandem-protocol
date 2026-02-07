# Planning Guide

**Stage:** Plan (PI Model)
**Focus:** Explore, understand, design - "What exists? Do I understand? How should we do this?"

## Exploration Lessons

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

## Understanding Lessons

### Confidence: Grade understanding before proceeding
**Context:** After exploration, before committing to a plan
**Lesson:** Explicitly assess confidence level (A-F) in understanding before moving forward
**Source:** UC9 seed

### Assumptions: Identify assumptions explicitly
**Context:** When forming mental model of requirements or constraints
**Lesson:** List assumptions separately from facts; mark confidence level for each
**Source:** UC9 seed

### Gaps: Surface clarifying questions early
**Context:** When gaps exist between requirements and understanding
**Lesson:** Ask questions before planning rather than discovering gaps during implementation
**Source:** UC9 seed

## Design Lessons

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
**Source:** README restructure session - 259 -> 114 lines by leading with value

### Explicit Behavioral Instructions: Include admin calls in plan files
**Context:** When creating plan files for multi-phase work
**Lesson:** Plan files MUST include explicit TaskAPI and logging instructions at gate trigger points. Templates aren't enough - the specific calls must be written into the plan.
**Source:** UC10 compliance failure - plan files missing explicit instructions led to drift

### Gate Verification: Checklist before approval
**Context:** Before requesting "May I proceed?"
**Lesson:** Include checklist in plan file: verify TaskAPI sections exist, verify logging sections exist. Don't request approval without these.
**Source:** UC10 T5 test - verification checklist prevents compliance drift

## Usage Example

Subagent returns structured output referencing lessons:

```markdown
### Lessons Applied
- "Patterns: Check for existing patterns first": Found error handling in pkg/errors before proposing new pattern
- "Criteria: Define success criteria before implementation": Specified 4 measurable criteria

### Lessons Missed
- "Dependencies: Verify dependencies early": Did not check downstream consumers until implementation
```
