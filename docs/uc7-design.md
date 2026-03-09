# UC7 Design: Event Logging

## Design

**Location:** README.md - Implementation Gate actions, Completion Gate actions, grading cycle sections

**Design principle:** All events published to Era via `mk` commands. Era is the single event store — no local log files.

### Event Types and Commands

| Type | When | mk Command | Format |
|------|------|------------|--------|
| Contract | Implementation Gate | `mk contract << 'TOML'` | TOML heredoc with `[[criteria]]` entries |
| Completion | Completion Gate | `mk complete << 'TOML'` | TOML attestation composed at completion time |
| Interaction | `/i` `/c` `/g` at gates | `mk interaction` | `mk interaction "/i -> missing edge case, added"` |
| Task | Implementation Gate | `mk task` | `mk task "Phase 1 - auth"` |
| Task-done | Completion Gate | `mk done` | `mk done <id> "Phase 1 complete"` |

### Contract/Completion TOML Format

**Contract:** TOML with phase and `[[criteria]]` entries (names only).
**Attestation:** LLM composes at completion time — each criterion gets a status.

**Statuses:**
- `delivered` = completed, with `evidence` field
- `dropped` = not delivered, with `reason` field
- `added` = discovered during implementation, with `evidence` field

`mk complete` validates that every contract criterion appears in the attestation.

### Protocol Integration

| Protocol Step | Event Type | Command |
|---------------|------------|---------|
| Step 2 (Impl Gate) | Contract + Task | `mk contract` + `mk task` |
| Steps 2/4 (grading) | Interaction | `mk interaction` |
| Step 4 (Compl Gate) | Completion + Task-done | `mk complete` + `mk done` |

### Example Event Flow

```bash
mk contract << 'TOML'
phase = "Phase 1 - auth middleware"

[[criteria]]
name = "middleware"

[[criteria]]
name = "tests"

[[criteria]]
name = "docs"
TOML
mk task "Phase 1 - auth middleware"
# ... implementation ...
mk interaction "/i -> missing edge case handling, added"
mk interaction "/c -> naming violation per Go guide, fixed"
mk complete << 'TOML'
phase = "Phase 1"

[[criteria]]
name = "middleware"
status = "delivered"
evidence = "auth.go:45"

[[criteria]]
name = "tests"
status = "delivered"
evidence = "auth_test.go:12"

[[criteria]]
name = "docs"
status = "delivered"
evidence = "README:12"
TOML
mk done 14752 "Phase 1 complete"
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | mk contract at Implementation Gate | `mk contract` |
| T2 | mk complete at Completion Gate | `mk complete` |
| T3 | mk interaction at grading | `mk interaction` |
| T4 | No plan-log.md references | NOT `plan-log` |
