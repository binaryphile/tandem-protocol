# UC8-B Design: Todo Integration with Plan File

## Design

**Location:** tandem-protocol.md - Step 2 (start) and Step 6d

**Design principle:** Plan file IS the todo state. No separate tracking.

**Current state:** Protocol mentions TodoWrite but plan file and todos are separate artifacts.

**Problem:** Observed drift between plan state and todo state. User had to remind about telescoping.

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
- [pending] UC3-C: Implementation (Steps 2-6)
""")

# Sync to TodoWrite if available
if tool_available("TodoWrite"):
    TodoWrite(read_todos_from_plan())
```

### Change 2: Step 6d - Collapse and expand

**Location:** Step 6d, replace current content (~line 738)

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
- [pending] UC4-C: Implementation (Steps 2-6)
""")

# Sync to TodoWrite
if tool_available("TodoWrite"):
    TodoWrite(read_todos_from_plan())
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
| Step 6d collapse/expand | +10 |
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
2. Update Step 6d with collapse/expand
3. Verify T1-T3 PASS

### Phase 3: REFACTOR
1. Ensure plan file template example is clear
