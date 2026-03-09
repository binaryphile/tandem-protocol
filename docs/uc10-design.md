# UC10 Design: Task Claiming

## Design

**Location:** README.md (plan template Implementation Gate block), FEATURES.md (Task Management section)

**Design principle:** Claims are event-sourced — derived from the stream, not stored as mutable state. Task-audit reconciles task/done/claim/unclaim events to compute current state.

### Task Lifecycle Commands

| Command | Event Type | Metadata | Purpose |
|---------|-----------|----------|---------|
| `mk task "desc"` | `task` | — | Create task, returns ID |
| `mk claim <id> <name>` | `claim` | `refs=<id>,claimer=<name>` | Assign task to agent |
| `mk unclaim <id>` | `unclaim` | `refs=<id>` | Release assignment |
| `mk done <id> "evidence"` | `task-done` | `refs=<id>` | Complete task (releases claim) |

### Inspection Commands

| Command | Action |
|---------|--------|
| `mk open` | List open (uncompleted) tasks |
| `mk claims` | List active claims (on open tasks only) |
| `mk audit` | Full reconciliation: total, matched, open |

### Protocol Integration

Implementation Gate bash block:
```bash
mk task "Phase 1 - objective"
# Note the task ID from output, then:
mk claim <task-id> claude
```

Completion Gate bash block:
```bash
mk done <task-id> "Phase 1 complete"
# No explicit unclaim needed — done releases claims
```

### Claim Reconciliation (task-audit)

State derived from event stream:
- `task` event → task exists (open)
- `task-done` event with `refs` → task completed (removes from open, releases claims)
- `claim` event with `refs` → task claimed by `claimer`
- `unclaim` event with `refs` → claim released

**Rules:**
- Done tasks filter out of `mk open` and `mk claims`
- Last-writer-wins for claims (re-claiming overwrites)
- `mk claim` warns if already claimed but publishes anyway

### Claim Check Logic

`mk claim` calls `task-audit check <stream> <id>`:
- Exit 0: not claimed (or done) → proceed silently
- Exit 1: already claimed → print claimer, `mk claim` warns

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | mk claim in plan template | `mk claim` in Implementation Gate |
| T2 | mk done at Completion Gate | `mk done` in Completion Gate |
| T3 | Task Management in FEATURES.md | `Task Management` |
