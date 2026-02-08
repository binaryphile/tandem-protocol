# UC7 Design: Event Logging

## Design

**Location:** README.md - multiple steps (1d, 1e, 2b, 3b, 4a)

**Design principle:** Log to plan-log.md at step boundaries, not intermediate files.

### Entry Format

```
YYYY-MM-DDTHH:MM:SSZ | Type: description | [checkboxes with evidence]
```

**Contract entry:** Lists criteria with `[ ]` checkboxes
**Completion entry:** Copies criteria verbatim, fills `[x]/[-]/[+]` with evidence

**Markers:**
- `[x]` = completed with evidence
- `[ ]` = not completed (failure)
- `[-]` = removed (with reason)
- `[+]` = added (with reason)

### Entry Types

| Type | When | Purpose |
|------|------|---------|
| Contract | Step 1d (phase start) | Captures scope/deliverables/criteria |
| Completion | Results delivered | Tracks criteria met against contract |
| Interaction | User input | Records feedback, g/i cycles |

### Protocol Integration

| Step | Action |
|------|--------|
| 1d | Log `Contract:` entry (scope, criteria) |
| 1e | Log `Completion: Step 1` |
| 2b | Log `Completion: Step 2` (all criteria met against contract) |
| 3a | Present results with "Upon your approval" listing Step 4 substeps |
| 3b | Log `Interaction:` on user feedback |
| 4a | Log `Completion: Phase approved` |
| 4b | Commit deliverable + plan-log.md |
| 4c | Setup next phase (groom plan file, route lessons) |

### Step 3a Presentation Template

```
**Upon your approval, I will:**
1. Log Completion entry for Step 3
2. Step 4a: Log phase approval to plan-log.md
3. Step 4b: Commit deliverable + plan-log.md
4. Step 4c: Setup next phase (groom plan file, route lessons)

**May I proceed?**
```

### Example Log

```
2026-02-06T14:30:00Z | Contract: Phase 1 - auth middleware | [ ] middleware, [ ] tests, [ ] docs
2026-02-06T14:35:00Z | Completion: Step 1 - plan validated, approval received
2026-02-06T15:00:00Z | Interaction: /p grade -> B/84, missing edge case handling
2026-02-06T15:05:00Z | Interaction: /i improve -> added edge case
2026-02-06T15:30:00Z | Completion: Step 2 | [x] middleware (auth.go:45), [x] tests (auth_test.go), [x] docs (README:12)
2026-02-06T15:45:00Z | Interaction: /w grade -> A-/91; /i -> fixed edge case
2026-02-06T15:50:00Z | Completion: Phase 1 approved

# Example with changes:
2026-02-06T16:00:00Z | Completion: Step 2 | [x] middleware (auth.go:45), [-] tests (deferred: user approved), [+] logging (added: dependency)
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Contract entry format with checkboxes | `Contract:.*\[ \]` |
| T2 | Completion entry format with filled checkboxes | `Completion:.*\[x\]` |
| T3 | Interaction entry format | `Interaction:.*->` |
| T4 | No contract file references | NOT `phase-.*-contract.md` |
| T5 | Completion copies Contract criteria | `copy.*Contract.*criteria\|criteria.*verbatim` |

