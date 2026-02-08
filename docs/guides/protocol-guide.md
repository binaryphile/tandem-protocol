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

### Environment Isolation: Override wrapper variables
**Context:** When running Claude sessions in isolated test directories
**Lesson:** `cd` alone doesn't isolate - nix wrappers may reset working directory via PROJECT_ROOT. Set `PROJECT_ROOT="$TEST_CWD"` before invoking claude. Also need CLAUDE.md + git init in workspace for Claude to recognize project root.
**Source:** Integration test isolation - traced bin/claude wrapper overriding test directory

### Test Infrastructure: Disable set -e around error capture
**Context:** When capturing return values from verification functions
**Lesson:** `set -e` causes script exit before `$?` is captured if function returns non-zero. Use `set +e` before verification calls, `set -e` after, or use `! command` to bypass errexit while preserving return value.
**Source:** Integration test debugging - verify_* functions exiting script, cleanup deleting evidence

### Hook Hygiene: Clear logs after hooks installed
**Context:** When using PreToolUse hooks to capture tool calls
**Lesson:** Install hooks first (pointing to test directory), then clear the log file. Otherwise stale hooks from previous runs capture unrelated sessions. Also sanitize grep -c output with `tr -d '[:space:]'` - it can contain newlines.
**Source:** Integration test debugging - tool log contained commands from interactive session

### Read Your Own Docs Before Guessing
**Context:** When documenting tool call formats or API usage
**Lesson:** Don't guess or invent formats - look up the actual documentation first. Use WebSearch and WebFetch to find official docs (e.g., code.claude.com/docs/en/hooks for tool_input schemas). Multiple wrong guesses waste turns and erode trust.
**Source:** TaskAPI documentation - tried XML, function-call syntax, and other invented formats before reading the hooks reference

### Format Alone Insufficient for Tool Invocation
**Context:** When documenting tool calls in protocol
**Lesson:** Showing precise JSON format matching tool_input schema doesn't guarantee invocation. Claude executes bash commands (directly actionable) but doesn't necessarily invoke described tools (requires interpretation). UC7 logging works; UC8 TaskAPI doesn't.
**Source:** Phase 4 TaskAPI investigation - JSON format correct but test Claude never called TaskCreate/TaskUpdate

### Commands Execute, Descriptions Don't
**Context:** When writing protocol instructions
**Lesson:** Bash heredoc commands get executed verbatim. Tool invocation instructions ("Use TaskCreate tool with these parameters") are interpreted, not executed. For reliable compliance, prefer executable commands over descriptions of actions.
**Source:** UC7 vs UC8 comparison - bash heredoc 100% compliance, TaskAPI invocation 0% compliance

### Rigorous Empirical Testing Required
**Context:** Before concluding a mechanism "can't be fixed"
**Lesson:** Run controlled A/B test with instrumentation before declaring something unfixable. Informal observations are insufficient - need quantifiable comparison (e.g., "2 calls WITH vs 0 calls WITHOUT").
**Source:** TaskAPI debugging - initial conclusion "system-reminder doesn't work" was based on informal test; rigorous A/B test showed 2 vs 0 difference

### Rule 9 Applies to Debugging Conclusions
**Context:** When debugging leads to "this can't work" conclusion
**Lesson:** "If you didn't fix it, it ain't fixed" applies to debugging conclusions too. Before accepting "unfixable", verify the negative claim with same rigor as you'd verify a fix. Otherwise you may abandon a working solution.
**Source:** TaskAPI debugging - nearly concluded system-reminder ineffective, then rigorous test showed it DOES trigger TaskAPI calls (2 vs 0)

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
