# UC1-B Design: Step 2b Sequencing Integration

## Current State Analysis

**Location:** tandem-protocol.md lines 190-209

**Current pseudocode:**
```python
questions = identify_ambiguities()
present(f"**Clarifying Questions:**\n{format_questions(questions)}")
wait_for_answers()
update_understanding_with_answers()
```

**Gap:** No enforcement that questions are ASKED vs EMBEDDED. Current code presents questions but doesn't prevent the common failure mode: writing questions into the plan file instead of asking user.

## Design Changes

### Change 1: Explicit Sequencing Rule (Prose)

**Add after "⛔ BLOCKING" marker:**
> Questions must be ASKED (via conversation or AskUserQuestion tool), not embedded in plan file. The plan file should contain ANSWERS, not open questions.

**Line impact:** +2 lines

### Change 2: Agent-Neutral Tool Integration

**Replace `present(questions)` with:**
```python
if tool_available("AskUserQuestion"):
    AskUserQuestion(questions)
else:
    present(f"**Clarifying Questions:**\n{format_questions(questions)}")
```

**Line impact:** +3 lines (net, replacing 1 line)

### Change 3: No-Questions Explicit Statement

**Add after `questions = identify_ambiguities()`:**
```python
if not questions:
    present("No clarifying questions—understanding is complete.")
    # Explicit statement serves as verification
else:
    # ask questions...
```

**Line impact:** +4 lines

### Change 4: Anti-Pattern Guard (Comment)

**Add comment before `update_understanding_with_answers()`:**
```python
# ANTI-PATTERNS (plan file must NOT contain):
# - "TBD", "to be determined", "open question"
# - "assuming X" without having asked about X
# - Questions formatted as statements
```

**Line impact:** +4 lines

## Total Line Impact

| Change | Lines Added | Lines Removed | Net |
|--------|-------------|---------------|-----|
| Sequencing rule | +2 | 0 | +2 |
| Tool integration | +4 | -1 | +3 |
| No-questions statement | +4 | 0 | +4 |
| Anti-pattern guard | +4 | 0 | +4 |
| **Total** | +14 | -1 | **+13** |

**Efficiency check:** +13 lines exceeds net-zero target.

### Mitigation: Consolidate with existing prose

**Remove lines 196-199 (verbose comment block):**
```python
# Always ask at least one question - if no ambiguities, ask about:
# - Scope boundaries ("Should X be included or excluded?")
# - Success criteria ("How will we verify completion?")
# - Edge cases ("What happens if Y?")
```
**Savings:** -4 lines

**Remove line 206 (redundant WAIT comment):**
```python
# WAIT - do not proceed until user answers
```
**Savings:** -1 line

**Revised estimate:** +13 - 5 = **+8 lines**

Accept as P1 compliance fix requiring +8 lines from the +30 compliance buffer.

## Behavioral Test Cases (for UC1-C)

Based on UC1-A guard conditions. Tests verify tandem-protocol.md contains the required guidance.

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Explicit "ASKED not embedded" rule | `ASKED.*not.*embedded\|embedded.*not.*ASKED` |
| T2 | AskUserQuestion tool integration | `tool_available.*AskUserQuestion` |
| T3 | Fallback for no-tool case | `else:` AND `present.*[Qq]uestions` (both in Step 2b section) |
| T4 | No-questions explicit statement | `[Nn]o.*clarifying.*questions\|understanding.*complete` |
| T5 | Anti-pattern: TBD | `TBD\|to be determined\|open question` |
| T6 | Anti-pattern: assuming | `assuming.*without` |
| T7 | Plan contains ANSWERS rule | `ANSWERS.*not.*questions\|answers.*not.*open` |

**Test Logic:**
- T1-T4, T7: PASS if pattern found in tandem-protocol.md
- T5-T6: PASS if anti-pattern guidance mentions these terms

## Integration Points

- **tandem-protocol.md** lines 190-209: Step 2b pseudocode
- **tandem-protocol.md** line 287: TodoWrite substep reference (no change needed)
- **tests/**: New behavioral test file for UC1

## Files to Create/Modify

| File | Action |
|------|--------|
| tandem-protocol.md | Modify Step 2b section |
| tests/uc1-step1b.sh | Create behavioral tests |

## UC1-C Implementation Sequence (Red/Green TDD)

**STRICT ORDER - Do not deviate:**

### Phase 1: RED (Write Failing Tests)
1. Create `tests/uc1-step1b.sh`
2. Implement T1-T7 as executable checks
3. Run tests against current tandem-protocol.md
4. **Verify: All relevant tests FAIL** (proves tests detect the gap)

### Phase 2: GREEN (Implement Minimum to Pass)
1. Apply Change 1 (sequencing rule prose)
2. Run tests - check which pass
3. Apply Change 2 (tool integration)
4. Run tests - check which pass
5. Apply Change 3 (no-questions statement)
6. Run tests - check which pass
7. Apply Change 4 (anti-pattern guard)
8. **Verify: All tests PASS**

### Phase 3: REFACTOR (If Needed)
1. Review for line count optimization
2. Apply mitigations if over budget
3. **Verify: Tests still pass after refactor**

## Gating Between Phases

| Transition | Gate | Action |
|------------|------|--------|
| UC1-A complete | Gate 2 | Grade use case doc, improve until A-, user approval |
| UC1-A → UC1-B | Archive | Archive UC1-A, create UC1-B contract |
| UC1-B complete | Gate 2 | Grade design, improve until A-, user approval |
| UC1-B → UC1-C | Archive | Archive UC1-B, create UC1-C contract |
| UC1-C complete | Gate 2 | Grade implementation, improve until A-, user approval |
| UC1-C → UC2-A | Archive | Archive UC1 complete, create UC2-A contract |

**Gate 2 = grade/improve cycle until:**
- Grade ≥ A- (90+), OR
- Remaining gaps require unavailable data/next phase work
