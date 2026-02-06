# UC6-B Design: Lesson Capture from Grading

## Design

**Location:** tandem-protocol.md - Appendix: Grading Rubric (after line 928)

**Design principle:** Protocol covers main success path only. Exceptional cases omitted.

**Current state:** Grading rubric lists deduction categories but doesn't distinguish actionable gaps from non-actionable lessons.

**Problem:** Observed behavior where non-actionable items inflate grades, or insights get lost because they're not captured anywhere.

## Change

Add actionability test guidance to grading rubric preamble.

**Location:** After "Use this rubric for self-assessment" line (~928)

```python
# Before each deduction, apply actionability test:
# "Can I fix this now?" (in scope, in session, no pending decisions)
#   YES → Include as deduction
#   NO  → Capture in appropriate guide, don't deduct
```

## Line Budget

| Change | Lines |
|--------|-------|
| Actionability test comment | +4 |
| **Total** | **+4** |

UC6 budget: +81 lines available. Using +4 leaves +77 for UC7 if needed.

**Rationale for minimal approach:** The actionability test is a simple decision rule. Claude can reason through the routing (which guide, etc.) without explicit protocol guidance. Encoding the decision point is sufficient.

## Behavioral Test Cases (for UC6-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Actionability test at grading | `[Aa]ctionab.*test\|[Cc]an I fix this now` |
| T2 | Non-actionable → guide routing | `guide.*not.*deduct\|capture.*guide` |

## UC6-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc6-lesson-capture.sh` with T1-T2 tests
2. Run against current protocol - expect FAIL

### Phase 2: GREEN
1. Add actionability test to grading rubric preamble
2. Verify T1-T2 PASS

### Phase 3: REFACTOR
1. Already minimal - no refactoring needed
