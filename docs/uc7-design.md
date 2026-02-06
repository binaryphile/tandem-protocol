# UC7-B Design: Interaction Logging

## Design

**Location:** tandem-protocol.md - Step 4 (Update Contract)

**Design principle:** Protocol covers main success path only. Exceptional cases omitted.

**Current state:** Contract template has Self-Assessment section but no Interactions section.

**Problem:** Session flow isn't captured; behavioral patterns not visible for analysis.

## Change

Add Interactions section template to contract update in Step 4.

**Location:** Step 4, after Self-Assessment section (~line 556)

```python
# Add interaction log
append_to_contract("""
### Interactions

| Action | Response | Outcome |
|--------|----------|---------|
| [user input] | [LLM action] | [result] |
""")
```

## Line Budget

| Change | Lines |
|--------|-------|
| Interactions template | +6 |
| **Total** | **+6** |

Remaining after UC7: +48 - 6 = +42 lines available.

## Behavioral Test Cases (for UC7-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Interactions section in contract template | `### Interactions\|Interaction.*log` |
| T2 | Table format for logging | `Action.*Response.*Outcome` |

## UC7-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc7-interaction-logging.sh` with T1-T2 tests
2. Run against current protocol - expect FAIL

### Phase 2: GREEN
1. Add Interactions section to Step 4 contract template
2. Verify T1-T2 PASS

### Phase 3: REFACTOR
1. Already minimal - no refactoring needed
