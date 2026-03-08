# UC9 Design: Grading Cycles & Task Events

## Design

**Location:** README.md (overview diagram, plan template gates, Completion Gate section), FEATURES.md (Self-Grading, Event Logging, Multi-Phase)

**Design principles:**
- Diagrams show structure; text explains sequences. Keep mermaid clean.
- Gate events use `mk` (which calls `era publish`), not direct `era publish`. This ensures stream names derive from PROJECT_ROOT, eliminating the `<project>` variable.
- Interaction events (/i /c /g) log to plan-log.md only — they're session-internal feedback, not task lifecycle events.

### Grading Model

Simplified from old `/w /a /i` → `/w /i` pattern to repeated `/i` cycles:

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

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | `/i` command in Completion Gate | `On \x60/i\x60` |
| T2 | `/c` command in Completion Gate | `On \x60/c\x60` |
| T3 | `/g` command in Completion Gate | `On \x60/g\x60` |
| T4 | Grading loop in overview diagram | `/i /c /g` |
| T5 | No old grade/improve actions | NOT `On "grade"` AND NOT `On "improve"` |
| T6 | mk task in Implementation Gate template | `mk task` |
| T7 | mk done in Completion Gate template | `mk done` |
| T8 | No direct era publish in templates | NOT `era publish` in gate blocks |
