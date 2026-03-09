# UC9 Design: Grading Cycles & Task Events

## Design

**Location:** README.md (overview diagram, plan template gates, Implementation Gate section, Completion Gate section), FEATURES.md (Grading Cycles, Event Logging, Multi-Phase)

**Design principles:**
- Diagrams show structure; text explains sequences. Keep mermaid clean.
- Gate events use `mk` (which calls `era publish`), not direct `era publish`. This ensures stream names derive from PROJECT_ROOT, eliminating the `<project>` variable.
- All protocol events use `mk` commands (which call `era publish`): `mk contract`, `mk complete`, `mk interaction`, `mk task`, `mk done`.

### Grading Model

Repeated `/i` cycles at gates, with auto-cycling before initial presentation:

| Command | Action | When |
|---------|--------|------|
| `/g` | Apply external review feedback + fix | Once, at initial gate presentation (calibrated projects only) |
| `/i` | Self-assess + fix in one step | Default — repeated until exhausted |
| `/c` | Grade against project guides + fix | After `/i` cycles plateau |

### Task Event Model

| Gate | mk command | Era event type |
|------|-----------|----------------|
| Implementation Gate | `mk task "description"` | `task` |
| Completion Gate | `mk done <task-id> "evidence"` | `task-done` |

`<task-id>` is the era event ID returned by `mk task` — record it at Implementation Gate, substitute into Completion Gate's `mk done`.

### Event Types

| Event | Source | Destination | Mechanism |
|-------|--------|-------------|-----------|
| Interaction | `/i` `/c` `/g` at either gate | Era stream | `mk interaction "/i -> description"` |
| Task | Implementation Gate | Era stream | `mk task "description"` |
| Task-done | Completion Gate | Era stream | `mk done <task-id> "evidence"` |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | `/i` command in both gate sections | `On \x60/i\x60` |
| T2 | `/c` command in both gate sections | `On \x60/c\x60` |
| T3 | `/g` command in both gate sections | `On \x60/g\x60` |
| T4 | Grading loop in overview diagram | `/i /c /g` |
| T5 | No old grade/improve actions | NOT `On "grade"` AND NOT `On "improve"` |
| T6 | mk task in Implementation Gate template | `mk task` |
| T7 | mk done in Completion Gate template | `mk done` |
| T8 | No direct era publish in templates | NOT `era publish` in gate blocks |
