# UC8-B Design: Todo Integration with Plan File

## Design

**Location:** tandem-protocol.md - Step 1 (start) and Step 4c

**Design principle:** Plan file (document) and Tasks API (tool) are separate but synchronized.
- **Plan file** (~/.claude/plans/*.md): Document with phase structure, groomed as phases complete
- **Tasks API** (TaskCreate/Update/List): Tool for progress tracking, synced from plan file

**Current state:** Protocol mentions Tasks API but plan file and tasks are separate artifacts.

**Problem:** Observed drift between plan state and todo state. User had to remind about telescoping.

## Telescoping Pattern

When entering a step, telescope tasks:
- **Collapse completed steps** to single task (status: completed)
- **Expand current step** to show deliverables (status: in_progress/pending)
- **Keep pending steps** collapsed (status: pending)
- **Show all phases** - future phases visible as pending, not hidden

**Example: Phase 1, Step 2 with 3 deliverables and 3 more phases**

```
[completed] Step 1: Plan Validation
[in_progress] Step 2: Update tandem-protocol.md
[pending] Step 2: Update UC7 docs
[pending] Step 2: Create protocol-guide.md
[pending] Step 3: Present and await approval
[pending] Step 4: Post-approval actions
[pending] Phase 2: Plan File Lifecycle      ← future phase (collapsed)
[pending] Phase 3: UC Audit                 ← future phase (collapsed)
[pending] Phase 4: README Rewrite           ← future phase (collapsed)
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

When sketching initial plan:

```markdown
## Phase List (Todo State)

### Completed
(none yet)

### Current Phase
- [pending] UC1-A: Use case doc
- [pending] UC1-B: Design doc
- [pending] UC1-C: Implementation

### Pending Phases (collapsed)
- [pending] UC2: Plan/contract distinction
- [pending] UC3: Plan mode entry
- [pending] UC4-UC5: Compliance fixes
- [pending] UC6-UC7: New features (may cut)
```

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
