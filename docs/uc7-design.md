# UC7 Design: Event Logging

## Design

**Location:** README.md - Implementation Gate actions, Completion Gate actions, grading cycle sections

**Design principle:** All events published to Era via `evtctl` commands. Era is the single event store — no local log files.

### Event Types and Commands

| Type | When | evtctl Command | Format |
|------|------|------------|--------|
| Contract | Implementation Gate | `evtctl contract << 'JSONL'` | JSONL heredoc — one criterion per line |
| Completion | Completion Gate | `evtctl complete << 'JSONL'` | JSONL attestation composed at completion time |
| Interaction | `/i` `/c` `/g` at gates | `evtctl interaction` | `evtctl interaction "/i -> missing edge case, added"` |
| Task | Implementation Gate | `evtctl task` | `evtctl task "Phase 1 - auth"` |
| Task-done | Completion Gate | `evtctl done` | `evtctl done <id> "Phase 1 complete"` |

### Contract/Completion Format

**Contract:** JSONL with phase header + one criterion per line (names only).
**Attestation:** LLM composes at completion time — each criterion gets a status.

**Statuses:**
- `delivered` = completed, with `evidence` field
- `dropped` = not delivered, with `reason` field
- `added` = discovered during implementation, with `evidence` field

`evtctl complete` validates that every contract criterion appears in the attestation.

### Protocol Integration

| Protocol Step | Event Type | Command |
|---------------|------------|---------|
| Step 2 (Impl Gate) | Contract + Task | `evtctl contract` + `evtctl task` |
| Steps 2/4 (grading) | Interaction | `evtctl interaction` |
| Step 4 (Compl Gate) | Completion + Task-done | `evtctl complete` + `evtctl done` |

### Example Event Flow

```bash
evtctl contract << 'JSONL'
{"phase":"Phase 1 - auth middleware"}
{"name":"middleware"}
{"name":"tests"}
{"name":"docs"}
JSONL
evtctl task "Phase 1 - auth middleware"
# ... implementation ...
evtctl interaction "/i -> missing edge case handling, added"
evtctl interaction "/c -> naming violation per Go guide, fixed"
evtctl complete << 'JSONL'
{"name":"middleware","status":"delivered","evidence":"auth.go:45"}
{"name":"tests","status":"delivered","evidence":"auth_test.go:12"}
{"name":"docs","status":"delivered","evidence":"README:12"}
JSONL
evtctl done 14752 "Phase 1 complete"
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | evtctl contract at Implementation Gate | `evtctl contract` |
| T2 | evtctl complete at Completion Gate | `evtctl complete` |
| T3 | evtctl interaction at grading | `evtctl interaction` |
| T4 | No plan-log.md references | NOT `plan-log` |
