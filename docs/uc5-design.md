# UC5-B Design: Line Reference Guidance

## Design

**Location:** README.md - Step 4 (Update Contract)

**Design principle:** Protocol covers main success path only. Exceptional cases omitted.

**Current state:** Step 4 already references line numbers in contract updates (lines 513, 520) but no reminder to verify after edits.

**Problem:** Observed failures where line numbers become stale after edits but aren't updated.

## Change

Add comment reminding to verify line references before updating contract.

**Location:** Step 4, before contract update block (~line 504)

```python
# After edits: verify line references still accurate (numbers shift)
update_contract("""
...
```

## Line Budget

| Change | Lines |
|--------|-------|
| Comment at Step 4 | +1 |
| **Total** | **+1** |

Total UC4+UC5: +0 + +1 = +1 line. Well within budget.

## Behavioral Test Cases (for UC5-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Line reference verification guidance | `verify.*line\|line.*shift\|numbers.*shift` |

## UC5-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc5-line-reference.sh` with T1 test
2. Run against current protocol - expect FAIL

### Phase 2: GREEN
1. Add comment to Step 4
2. Verify T1 PASS

### Phase 3: REFACTOR
1. Already minimal - no refactoring needed
