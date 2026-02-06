# Protocol Guide

**Focus:** Meta-level lessons about protocol design and structure

**Note:** This is the sensible place to put lessons learned from reviewing behavioral logging in plan-log.md (Interaction entries, grade/improve cycles, feedback patterns). IAPI guides are for cognitive stages; this guide is for protocol process improvements.

## Lessons

### Locality: Instructions must be at point of use
**Context:** When placing instructions in protocol steps
**Lesson:** Instructions placed later in the flow won't be in attention when the action is needed. Place instructions where they'll be quoted/read, not deferred to later steps.
**Example:** Task creation instructions in Step 1d aren't seen when executing Step 1 entry. Move to Step 1 entry.
**Source:** UC7 enhancement - task creation locality

### Terminology: Use consistent, clear terms
**Context:** When describing protocol actions
**Lesson:** Use "expand" not "blow out", "collapse" not "telescope up". Clear terminology aids understanding.
**Source:** UC7 enhancement - terminology review

## Usage Example

When reviewing protocol changes:

```markdown
### Lessons Applied
- "Locality: Instructions must be at point of use": Moved TaskCreate to Step 1 entry where it's quoted

### Lessons Missed
- "Terminology: Use consistent, clear terms": Used "blow out" instead of "expand"
```
