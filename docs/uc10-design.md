# UC10 Design: Task Claiming

## Design

**Location:** README.md (plan template Implementation Gate block), FEATURES.md (Task Management section)

**Design principle:** Claims are event-sourced — derived from the stream, not stored as mutable state. Task-audit reconciles task/done/claim/unclaim events to compute current state.

### Task Lifecycle Commands

| Command | Event Type | Metadata | Purpose |
|---------|-----------|----------|---------|
| `evtctl task "desc"` | `task` | — | Create task, returns ID |
| `evtctl claim <id> <name>` | `claim` | `refs=<id>,claimer=<name>` | Assign task to agent |
| `evtctl unclaim <id>` | `unclaim` | `refs=<id>` | Release assignment |
| `evtctl done <id> "evidence"` | `task-done` | `refs=<id>` | Complete task (releases claim) |

### Inspection Commands

| Command | Action |
|---------|--------|
| `evtctl open` | List open (uncompleted) tasks |
| `evtctl claims` | List active claims (on open tasks only) |
| `evtctl audit` | Full reconciliation: total, matched, open |

### Protocol Integration

Implementation Gate bash block:
```bash
evtctl task "Phase 1 - objective"
# Note the task ID from output, then:
evtctl claim <task-id> claude
```

Completion Gate bash block:
```bash
evtctl done <task-id> "Phase 1 complete"
# No explicit unclaim needed — done releases claims
```

### Claim Reconciliation (task-audit)

State derived from event stream:
- `task` event → task exists (open)
- `task-done` event with `refs` → task completed (removes from open, releases claims)
- `claim` event with `refs` → task claimed by `claimer`
- `unclaim` event with `refs` → claim released

**Rules:**
- Done tasks filter out of `evtctl open` and `evtctl claims`
- Last-writer-wins for claims (re-claiming overwrites)
- `evtctl claim` warns if already claimed but publishes anyway

### Claim Check Logic

`evtctl claim` calls `task-audit check <stream> <id>`:
- Exit 0: not claimed (or done) → proceed silently
- Exit 1: already claimed → print claimer, `evtctl claim` warns

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | evtctl claim in plan template | `evtctl claim` in Implementation Gate |
| T2 | evtctl done at Completion Gate | `evtctl done` in Completion Gate |
| T3 | Task Management in FEATURES.md | `Task Management` |
