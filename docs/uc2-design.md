# UC2-B Design: Plan Mode & File Distinction Integration

## Current State Analysis

**Location:** tandem-protocol.md lines 219-246 (Step 2c)

**Current pseudocode:**
```python
# Present plan summary for approval
present(...)

# WAIT for explicit approval
wait_for("proceed", "yes", "approved")

# Exit plan mode - enables write operations for contract creation
if tool_available("ExitPlanMode"):
    ExitPlanMode()
    # Plan mode restrictions lifted
    # Can now create files, make edits, run commands
```

**Gap:** No guidance on file distinction (HOW vs WHAT) or verification that content is in correct file.

## Design Changes

### Change 1: Add file distinction comment block after ExitPlanMode

**Location:** After line 245, before closing ```

```python
if tool_available("ExitPlanMode"):
    ExitPlanMode()
    # Plan mode restrictions lifted
    # Can now create files, make edits, run commands

    # FILE DISTINCTION (plan file vs contract file):
    # Plan file (~/.claude/plans/): HOW - approach, methodology, phasing
    # Contract file (project dir): WHAT - scope, deliverables, success criteria
    # Plan file persists across phases; contract is per-phase working doc
```

**Line impact:** +4 lines

### Mitigation: Remove redundant comments

Current lines 244-245:
```python
    # Plan mode restrictions lifted
    # Can now create files, make edits, run commands
```

Replace with file distinction block (net change: +2 lines)

**Final line impact:** +2 lines

## Behavioral Test Cases (for UC2-C)

Tests verify tandem-protocol.md contains the required guidance.

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Plan file = HOW | `[Pp]lan file.*HOW\|HOW.*plan` |
| T2 | Contract file = WHAT | `[Cc]ontract.*WHAT\|WHAT.*contract` |
| T3 | Plan file location | `~/.claude/plans/\|plans/` |
| T4 | Plan persists across phases | `persist.*phase\|across.*phase` |

**Test Logic:** PASS if pattern found in Step 2c section of tandem-protocol.md

## Integration Points

- **tandem-protocol.md** lines 241-246: Step 2c ExitPlanMode block

## Files to Create/Modify

| File | Action |
|------|--------|
| tandem-protocol.md | Modify Step 2c section |
| tests/uc2-plan-mode.sh | Create behavioral tests |

## UC2-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc2-plan-mode.sh` with T1-T4 tests
2. Run against current protocol
3. Verify tests FAIL

### Phase 2: GREEN
1. Replace lines 244-245 with file distinction block
2. Verify tests PASS

### Phase 3: REFACTOR
1. Tune for efficiency
2. Verify tests still pass

## Line Budget

| Item | Lines |
|------|-------|
| Remove redundant comments | -2 |
| Add file distinction block | +4 |
| **Net** | **+2** |

Compliance buffer used: UC1 (+5) + UC2 (+2) = +7 of +30 available.
