# Protocol Guide

**Focus:** Meta-level lessons about protocol design and structure

**Note:** This is the place for lessons learned from reviewing behavioral logging in plan-log.md (Interaction entries, grade/improve cycles, feedback patterns). The planning guide is for cognitive stages; this guide is for protocol process improvements.

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

### Telescoping: Delete completed substeps from TaskAPI
**Context:** After completing a step's substeps
**Lesson:** Delete completed substep tasks and mark parent step complete. Don't let completed substeps accumulate in the task list.
**Source:** README restructure session - repeated telescoping failures

### Interaction Logging: Use explicit append_to_log
**Context:** During grade/improve cycles in Step 3b
**Lesson:** Abstract calls like `log_interaction()` don't show the required format, leading to omission. Explicit `append_to_log("plan-log.md", f"{timestamp} | Interaction: ...")` ensures compliance.
**Source:** README restructure session - Interaction entries not logged

### Substep Naming: Use letter suffixes
**Context:** When expanding steps into deliverables
**Lesson:** Name substeps as `Step 2a:`, `Step 2b:`, `Step 2c:` (not just "Step 2: deliverable").
**Source:** README restructure session - inconsistent naming

### Purge on Collapse: Remove completed phase detail
**Context:** When collapsing a completed phase in plan file
**Lesson:** Delete all detail, keep only single `[x]` line. Detail is in git history if needed.
**Source:** README restructure session - keeping too much detail

### Deferred Planning: Skeleton future phases
**Context:** When structuring multi-phase plan files
**Lesson:** Future phases should be one-line skeletons with expansion instructions. Planning happens when the phase arrives, not before.
**Source:** README restructure session - pre-planning future phases

### Enforcement at Locality: Templates need enforcement where used
**Context:** When protocol has templates for plan files or other artifacts
**Lesson:** A template sitting in a "Template" section won't be used. Add enforcement instruction AT the point where the artifact is created/finalized (e.g., "Before Gate 1, verify plan includes X").
**Source:** UC10 compliance testing - T1 failed, template existed but no enforcement at Gate 1

### Verification Gate: Checklist before approval request
**Context:** Before requesting "May I proceed?"
**Lesson:** Include explicit verification checklist immediately before approval requests. Without this, compliance drifts.
**Source:** UC10 compliance testing - T5 failed, no verification before approval

### Behavioral Testing: Grep patterns for compliance
**Context:** When defining protocol requirements
**Lesson:** If it can't be grep-tested, it's not enforceable. Define requirements as testable patterns.
**Source:** UC10 differential diagnosis - empirical tests revealed template vs enforcement gap

### Integration Test ≠ Post-hoc Verification
**Context:** When asked for "integration test" for protocol compliance
**Lesson:** Integration implies checking at integration points (gates), not just final state. Post-hoc artifact analysis misses timing/sequence violations.
**Source:** UC6+UC8 improvement session - built final-state checker when step-by-step verification was requested

### Checkpoint Polling vs FIFO Streaming
**Context:** When deciding test architecture for timing verification
**Lesson:** Checkpoint polling (verify after each gate) is sufficient for gate-level compliance. FIFO streaming adds complexity without proportional benefit - we need "did it happen at the right gate?" not millisecond precision.
**Source:** Integration test improvement - analyzed FIFO option, chose simpler approach

## Usage Example

When reviewing protocol changes:

```markdown
### Lessons Applied
- "Locality: Instructions must be at point of use": Moved TaskCreate to Step 1 entry where it's quoted
- "Telescoping: Delete completed substeps": Deleted Step 2a/2b tasks after completing Step 2

### Lessons Missed
- "Terminology: Use consistent, clear terms": Used "blow out" instead of "expand"
- "Interaction Logging: Use explicit append_to_log": Forgot to log grade/improve cycle
```
