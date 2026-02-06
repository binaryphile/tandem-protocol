# UC4-B Design: Verbatim Archive Rule

## Design

**Location:** tandem-protocol.md - Step 2e and Step 6b archive sections

**Design principle:** Protocol covers main success path only. Exceptional cases omitted.

**Current state:** Protocol already uses `cat` for archives, which IS verbatim. But no explicit guidance against summarizing.

**Problem:** Observed failures where Claude summarized instead of appending literally.

## Change

Add comment emphasizing verbatim requirement near existing `cat` commands.

**Location 1:** Step 2e (lines ~450-457)
```python
# Archive VERBATIM - no summarizing, no reformatting
cat(plan_file)      >> "plan-log.md"
cat(contract_file)  >> "plan-log.md"
```

**Location 2:** Step 6b (lines ~656-658)
```python
# Archive VERBATIM - no summarizing, no reformatting
cat(contract_file)  >> "plan-log.md"
```

## Line Budget

| Change | Lines |
|--------|-------|
| Comment at Step 2e | +1 |
| Comment at Step 6b | +1 |
| **Total** | **+2** |

Remaining after UC4: 6 - 2 = 4 lines for UC5.

## Behavioral Test Cases (for UC4-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Verbatim guidance at archive | `VERBATIM.*summar\|verbatim.*reformat` |
| T2 | cat command for archive | `cat.*plan-log\|cat.*>>` |

## UC4-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc4-verbatim-archive.sh` with T1-T2 tests
2. Run against current protocol
3. T1 should FAIL (no explicit verbatim), T2 should PASS (cat already exists)

### Phase 2: GREEN
1. Add verbatim comment to Step 2e
2. Add verbatim comment to Step 6b
3. Verify T1-T2 PASS

### Phase 3: REFACTOR
1. Already minimal - no refactoring needed
