# UC4-B Design: Verbatim Archive Rule

## Design

**Location:** tandem-protocol.md - Step 1e and Step 4b archive sections

**Design principles:**
- Protocol covers main success path only. Exceptional cases omitted.
- No change commentary in docs (e.g., "(was Step 2)", "(old: X)"). Rely on git for history.

**Current state:** Protocol already uses `cat` for archives, which IS verbatim. But no explicit guidance against summarizing.

**Problem:** Observed failures where Claude summarized instead of appending literally.

## Entry Format

**Grep-friendly format:**
```
YYYY-MM-DDTHH:MM:SSZ | Type: subject
```

**Entry types:**

| Type | When | What's Archived |
|------|------|-----------------|
| `Plan:` | Step 1e | Plan file from ~/.claude/plans/ |
| `Contract:` | Step 1e | New contract capturing approved scope |
| `Completion:` | Step 4b | Final contract with results |

**Examples:**
```
2026-02-05T14:30:00Z | Plan: Protocol Maintenance Updates
2026-02-05T14:30:00Z | Contract: Protocol Maintenance Updates
2026-02-05T16:45:00Z | Completion: Protocol Maintenance Updates
```

## Completion Entry Contents

A Completion entry archives the verbatim contract which contains:

| Section | Source | Purpose |
|---------|--------|---------|
| Step 1 Checklist | Contract | Track planning steps |
| Objective | Contract | What was agreed |
| Success Criteria | Contract | Acceptance criteria (all checked) |
| Approach | Contract | How it was done |
| Actual Results | Contract/Step 2 | What was delivered |
| Self-Assessment | UC6 | Grade + deductions |
| Interactions | UC7 | Action/response/outcome table |
| Step 3 Checklist | Contract | Track presentation steps |
| Approval record | Step 4a | User approval confirmation |

## Change

Add comment emphasizing verbatim requirement near existing `cat` commands.

**Location 1:** Step 1e ```python
# Archive VERBATIM - no summarizing, no reformatting
echo("YYYY-MM-DDTHH:MM:SSZ | Plan: [subject]") >> "plan-log.md"
cat(plan_file)      >> "plan-log.md"
echo("YYYY-MM-DDTHH:MM:SSZ | Contract: [subject]") >> "plan-log.md"
cat(contract_file)  >> "plan-log.md"
```

**Location 2:** Step 4b ```python
# Archive VERBATIM - no summarizing, no reformatting
echo("YYYY-MM-DDTHH:MM:SSZ | Completion: [subject]") >> "plan-log.md"
cat(contract_file)  >> "plan-log.md"
rm(contract_file)
```

## Line Budget

| Change | Lines |
|--------|-------|
| Comment at Step 1e | +1 |
| Comment at Step 4b | +1 |
| Entry format section | +15 |
| **Total** | **+17** |

## Behavioral Test Cases (for UC4-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Verbatim guidance at archive | `VERBATIM.*summar\|verbatim.*reformat` |
| T2 | cat command for archive | `cat.*plan-log\|cat.*>>` |
| T3 | Entry format specification | `YYYY-MM-DDTHH:MM:SSZ` |
| T4 | Three entry types | `Plan:\|Contract:\|Completion:` |

## UC4-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc4-verbatim-archive.sh` with T1-T4 tests
2. Run against current protocol
3. T1 should FAIL (no explicit verbatim), T2 should PASS (cat already exists)
4. T3 should FAIL (no format spec), T4 should FAIL (no entry types)

### Phase 2: GREEN
1. Add verbatim comment to Step 1e
2. Add verbatim comment to Step 4b
3. Add entry format and types to protocol
4. Verify T1-T4 PASS

### Phase 3: REFACTOR
1. Already minimal - no refactoring needed
