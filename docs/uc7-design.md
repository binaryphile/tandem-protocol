# UC7 Design: Event Logging

## Design

**Location:** README.md - Implementation Gate actions, Completion Gate actions, grading cycle sections

**Design principle:** All events published to Era via `mk` commands. Era is the single event store — no local log files.

### Event Types and Commands

| Type | When | mk Command | Example |
|------|------|------------|---------|
| Contract | Implementation Gate | `mk contract` | `mk contract "Phase 1 - auth \| [ ] middleware \| [ ] tests"` |
| Completion | Completion Gate | `mk complete` | `mk complete "Phase 1 \| [x] middleware (auth.go:45) \| [x] tests (pass)"` |
| Interaction | `/i` `/c` `/g` at gates | `mk interaction` | `mk interaction "/i -> missing edge case, added"` |
| Task | Implementation Gate | `mk task` | `mk task "Phase 1 - auth"` |
| Task-done | Completion Gate | `mk done` | `mk done <id> "Phase 1 complete"` |

### Contract/Completion Criteria Format

**Contract:** Lists criteria with `[ ]` checkboxes (pipe-separated)
**Completion:** Copies criteria, fills `[x]` with evidence

**Markers:**
- `[x]` = completed with evidence
- `[ ]` = not completed (failure)
- `[-]` = removed (with reason)
- `[+]` = added (with reason)

### Protocol Integration

| Protocol Step | Event Type | Command |
|---------------|------------|---------|
| Step 2 (Impl Gate) | Contract + Task | `mk contract` + `mk task` |
| Steps 2/4 (grading) | Interaction | `mk interaction` |
| Step 4 (Compl Gate) | Completion + Task-done | `mk complete` + `mk done` |

### Example Event Flow

```
mk contract "Phase 1 - auth middleware | [ ] middleware | [ ] tests | [ ] docs"
mk task "Phase 1 - auth middleware"
# ... implementation ...
mk interaction "/i -> missing edge case handling, added"
mk interaction "/c -> naming violation per Go guide, fixed"
mk complete "Phase 1 | [x] middleware (auth.go:45) | [x] tests (pass) | [x] docs (README:12)"
mk done 14752 "Phase 1 complete"
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | mk contract at Implementation Gate | `mk contract` |
| T2 | mk complete at Completion Gate | `mk complete` |
| T3 | mk interaction at grading | `mk interaction` |
| T4 | No plan-log.md references | NOT `plan-log` |
