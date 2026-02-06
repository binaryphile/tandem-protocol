# UC7 Design: Event Logging

## Design

**Location:** tandem-protocol.md - multiple steps (1d, 1e, 2, 4b, 5)

**Design principle:** Log directly to plan-log.md as events occur.

### Entry Format

```
YYYY-MM-DDTHH:MM:SSZ | Type: description
```

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
| 3b | Log `Interaction:` on user feedback |
| 4a | Log `Completion: Phase approved` |

### Example Log

```
2026-02-06T14:30:00Z | Contract: Phase 1 - implement auth middleware, 3 criteria (middleware, tests, docs)
2026-02-06T14:35:00Z | Completion: Step 1 - plan validated, approval received
2026-02-06T15:00:00Z | Interaction: /p grade → B/84, missing edge case handling
2026-02-06T15:05:00Z | Interaction: /i improve → added edge case
2026-02-06T15:30:00Z | Completion: Step 2 - 3/3 criteria met (middleware created, tests pass, docs updated)
2026-02-06T15:45:00Z | Interaction: /w grade → A-/91; /i → fixed edge case
2026-02-06T15:50:00Z | Completion: Phase 1 approved
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Contract entry format | `Contract:.*scope\|deliverables` |
| T2 | Completion entry format | `Completion:.*Step` |
| T3 | Interaction entry format | `Interaction:.*→` |
| T4 | No contract file references | NOT `phase-.*-contract.md` |

