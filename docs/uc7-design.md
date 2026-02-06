# UC7 Design: Event Logging

## Design

**Location:** tandem-protocol.md - multiple steps (1d, 1e, 2, 4b, 5)

**Design principle:** Log directly to plan-log.md as events occur. No contract file lifecycle.

**Current state:** Protocol uses contract files that get archived to plan-log.md at Step 5.

**Problem:** Contract file requires create/update/archive/delete lifecycle. Risk of forgetting to archive.

## Change

Replace contract file pattern with direct event logging to plan-log.md.

### Entry Format

```
YYYY-MM-DDTHH:MM:SSZ | Type: description
```

### Entry Types

| Type | When | Purpose |
|------|------|---------|
| Contract | Step 1d (phase start) | Captures scope/deliverables |
| Completion | Step completion | Tracks progress |
| Interaction | User input | Records feedback, g/i cycles |

### Protocol Integration

| Step | Current | New |
|------|---------|-----|
| 1d | Create `phase-N-contract.md` | Log `Contract:` entry |
| 1e | Archive plan + contract | Log `Completion: Step 1` |
| 3 | Update contract | Log `Completion: Step 2/3` |
| 4b | (implicit) | Log `Interaction:` on user input |
| 5b | Archive + delete contract | Log `Completion: Phase approved` |

### Example Log

```
2026-02-06T14:30:00Z | Contract: Phase 1 - implement auth middleware, 3 success criteria
2026-02-06T14:35:00Z | Completion: Step 1 - plan validated, approval received
2026-02-06T15:00:00Z | Interaction: /p grade → B/84, missing edge case handling
2026-02-06T15:05:00Z | Interaction: /i improve → added edge case
2026-02-06T15:30:00Z | Completion: Step 2 - auth.go created, 45 lines
2026-02-06T15:45:00Z | Interaction: /w grade → A-/91
2026-02-06T15:50:00Z | Completion: Phase 1 approved, all criteria met
```

## Line Budget

| Change | Lines |
|--------|-------|
| Remove contract file creation (Step 1d) | -20 |
| Remove contract update (Step 3) | -15 |
| Remove contract archive/delete (Step 5b) | -10 |
| Add event logging pattern | +15 |
| **Net** | **-30** |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Contract entry format | `Contract:.*scope\|deliverables` |
| T2 | Completion entry format | `Completion:.*Step` |
| T3 | Interaction entry format | `Interaction:.*→` |
| T4 | No contract file references | NOT `phase-.*-contract.md` |

## Implementation Sequence

### Phase 1: Update UC7 docs
1. ✓ Update use case (uc7-interaction-logging.md)
2. ✓ Update design (this file)

### Phase 2: Update protocol
1. Remove contract file creation from Step 1d
2. Add event logging to Steps 1d, 1e, 3, 4b, 5
3. Remove contract archive/delete from Step 5b
4. Update mermaid diagram if needed
