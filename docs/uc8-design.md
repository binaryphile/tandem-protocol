# UC8-B Design: Todo Integration with Plan File

## Design

**Location:** README.md - Step 1 (start) and Step 4c

**Design principle:** Plan file (document) and Tasks API (tool) are separate but synchronized.

| Artifact | Format | Lifecycle | Persistence |
|----------|--------|-----------|-------------|
| **Plan file** | `[x]`/`[ ]` checkboxes | skeleton → expand → collapse | Permanent (committed) |
| **Tasks API** | `completed/in_progress/pending` | create → update → delete | Session (ephemeral) |

**Sync direction:** Plan file → Tasks API (if Tasks API is used)

## Mechanism Selection

| Mechanism | Reliability | User Visibility |
|-----------|-------------|-----------------|
| **Plan file checkboxes** | 100% (bash heredoc) | Committed to git |
| **Tasks API** | Variable (no guaranteed trigger) | Spinner UI, session state |

**Primary mechanism:** Plan file checkboxes
- Always works (bash syntax triggers Bash invocation)
- Persists across sessions (committed)
- User can see progress in git diff

**Secondary mechanism:** Tasks API
- Protocol includes TaskCreate/TaskUpdate instructions
- System-reminder in CLAUDE.md reinforces attention
- Compliance is variable - Claude may or may not invoke
- Provides spinner UI when invoked

**Empirical finding:** System-reminder tags do not reliably trigger tool invocation. Tested 2026-02-08: TaskCreate not called despite explicit system-reminder instruction.

**Design principle:** Plan file guarantees tracking; TaskAPI is best-effort enhancement.
Tests should verify plan file compliance; TaskAPI compliance is bonus.

## Plan File Lifecycle

| State | Definition | Content |
|-------|------------|---------|
| **Skeleton** | Future phases | Description + local expansion instruction (planning deferred) |
| **Expanded** | Current phase | Full plan: objective, success criteria, changes, tasks, verification |
| **Collapsed** | Completed phases | Single line with `[x]`, detail PURGED |

**Key Principles:**
- **Collapse = purge**: Completed phase detail is removed entirely, not just marked done
- **Deferred planning**: Future phases are NOT planned until they become current
- **Fresh Plan stage**: Each phase starts with plan mode entry and exploration

```
[x] Phase 1: Auth middleware           ← collapsed (detail PURGED)

[ ] Phase 2: Event logging             ← expanded (full plan below)
    [Objective, Success Criteria, Changes, Tasks, Verification sections]

[ ] Phase 3: README update             ← skeleton (NOT planned yet)
*(Expand when this phase starts: run Plan stage, define success criteria, tasks)*
```

## Telescoping Pattern

**In Plan File (checkboxes):**
- **Collapsed completed phases**: Detail purged, single `[x]` line remains
- **Expanded current phase**: Full plan with objective, criteria, changes, tasks
- **Skeleton future phases**: Description + expansion instruction (planning deferred)

**In Tasks API (status):**
- **Collapse completed steps**: Mark `completed`, then delete at phase end
- **Expand current step**: Show deliverables as `Step Xa:`, `Step Xb:`, etc.
- **Keep pending steps**: Show as `pending`
- **Show future phases**: Single `pending` task per phase

**Substep naming:** When a step expands, substeps use letter suffixes: `Step 2a:`, `Step 2b:`, `Step 2c:`, etc.

**Example: Phase 1, Step 2 with 3 deliverables and 3 more phases**

```
[completed] Step 1: Plan Validation
[in_progress] Step 2a: Update README.md
[pending] Step 2b: Update UC7 docs
[pending] Step 2c: Create protocol-guide.md
[pending] Step 3: Present and await approval
[pending] Step 4: Post-approval actions
[pending] Phase 2: Plan File Lifecycle      ← future phase (skeleton)
[pending] Phase 3: UC Audit                 ← future phase (skeleton)
[pending] Phase 4: README Rewrite           ← future phase (skeleton)
```

**Note:** Use Tasks API status (completed/in_progress/pending), not checkbox markers in task subjects.

## Change

### Change 1: Step 2 - Expand current phase

**Location:** Step 2 start, after plan mode entry (~line 285)

```python
# Expand current phase in plan file to protocol steps
# Example: UC3 starting
update_plan_file("""
### Current Phase (expanded)
- [in_progress] UC3-A: Use case doc (Step 2)
- [pending] UC3-B: Design doc (Step 2)
- [pending] UC3-C: Implementation (Steps 1-5)
""")

# Sync to Tasks API if available
if tool_available("TaskCreate"):
    sync_tasks_from_plan()
```

### Change 2: Step 4c - Collapse and expand

**Location:** Step 4c, replace current content (~line 738)

```python
# Collapse completed phase in plan file
update_plan_file("""
### Completed (collapsed)
- [completed] UC3: Plan mode entry
""")

# Expand next phase
update_plan_file("""
### Current Phase (expanded)
- [in_progress] UC4-A: Use case doc (Step 2)
- [pending] UC4-B: Design doc (Step 2)
- [pending] UC4-C: Implementation (Steps 1-5)
""")

# Sync to Tasks API
if tool_available("TaskCreate"):
    sync_tasks_from_plan()
```

## Plan File Template

Plan file must include a **Tasks section** with pre-formatted TaskCreate JSON. This ensures deliverable-specific tasks are defined during planning (when context is fresh), not improvised during execution.

**Rationale:** Without pre-defined JSON, Claude must generate TaskCreate calls from scratch at Step 2, leading to inconsistent task definitions and missed deliverables. Defining tasks in the plan file provides locality - the task definitions live with the plan that created them.

```markdown
# [Phase Name] Plan

## Objective
[1-2 sentence summary]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Changes
### 1. [Change description]
[Details, file:line references]

## Tasks
Step 2 deliverables (copy to TaskCreate calls after approval):

    [
      {"subject": "[Deliverable 1]", "description": "[Details]", "activeForm": "[Verb]ing [noun]"},
      {"subject": "[Deliverable 2]", "description": "[Details]", "activeForm": "[Verb]ing [noun]"}
    ]

## Verification
[Commands to verify success criteria]

## Commit
[Commit message]
```

**Key requirement:** The Tasks JSON array is copied verbatim to TaskCreate calls after plan approval. This provides:
- **Locality:** Task definitions live with the plan
- **Consistency:** Same tasks every time the plan is executed
- **Completeness:** All deliverables captured during planning when context is fresh

## Line Budget

| Change | Lines |
|--------|-------|
| Step 2 expansion pseudocode | +8 |
| Step 4c collapse/expand | +10 |
| **Total** | **+18** |

## Behavioral Test Cases (for UC8-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Expand current phase in plan | `[Ee]xpand.*current.*phase\|current.*phase.*expand` |
| T2 | Collapse completed phase | `[Cc]ollapse.*completed\|completed.*collapse` |
| T3 | Plan file as todo source | `plan.*file.*todo\|read.*todos.*plan` |

## UC8-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Update `tests/uc8-phase-transition.sh` with T1-T3 tests
2. Run against current protocol - expect FAIL

### Phase 2: GREEN
1. Add expansion pseudocode to Step 2
2. Update Step 4c with collapse/expand
3. Verify T1-T3 PASS

### Phase 3: REFACTOR
1. Ensure plan file template example is clear

## Lessons Learned

### Three-Level Hierarchy Required
**Context:** When creating tasks for a phase
**Lesson:** TaskAPI should mirror three-level hierarchy: Phase → Stage (Plan/Implement) → Task. Creating flat deliverable tasks skips the Stage level, losing visibility into protocol progression.
**Source:** UC6+UC8 improvement session - created deliverable tasks directly without Plan/Implement stage tasks
