# UC9 Design: Grading Cycles & Task Events

## Design

**Location:** README.md (overview diagram, plan template gates, Implementation Gate section, Completion Gate section), FEATURES.md (Grading Cycles, Event Logging, Multi-Phase)

**Design principles:**
- Diagrams show structure; text explains sequences. Keep mermaid clean.
- Gate events use `mk` (which calls `era publish`), not direct `era publish`. This ensures stream names derive from PROJECT_ROOT, eliminating the `<project>` variable.
- All protocol events use `mk` commands (which call `era publish`): `evtctl contract`, `evtctl complete`, `evtctl interaction`, `evtctl plan`, `evtctl task`, `evtctl claim`, `evtctl done`.

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
| Implementation Gate | `evtctl task "description"` | `task` |
| Implementation Gate | `evtctl claim <task-id> claude` | `claim` |
| Completion Gate | `evtctl done <task-id> "evidence"` | `task-done` |

`<task-id>` is the era event ID returned by `evtctl task` — record it at Implementation Gate, use for `evtctl claim` and substitute into Completion Gate's `evtctl done`.

### Event Types

| Event | Source | Destination | Mechanism |
|-------|--------|-------------|-----------|
| Interaction | `/i` `/c` `/g` at either gate | Era stream | `evtctl interaction "/i -> description"` |
| Plan | Implementation Gate | Era stream | `evtctl plan ~/.claude/plans/<plan-name>.md` |
| Task | Implementation Gate | Era stream | `evtctl task "description"` |
| Claim | Implementation Gate | Era stream | `evtctl claim <task-id> claude` |
| Task-done | Completion Gate | Era stream | `evtctl done <task-id> "evidence"` |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | `/i` command in both gate sections | `On \x60/i\x60` |
| T2 | `/c` command in both gate sections | `On \x60/c\x60` |
| T3 | `/g` command in both gate sections | `On \x60/g\x60` |
| T4 | Grading loop in overview diagram | `/i /c /g` |
| T5 | No old grade/improve actions | NOT `On "grade"` AND NOT `On "improve"` |
| T6 | evtctl task in Implementation Gate template | `evtctl task` |
| T7 | evtctl done in Completion Gate template | `evtctl done` |
| T8 | No direct era publish in templates | NOT `era publish` in gate blocks |
| T9 | evtctl claim in Implementation Gate template | `evtctl claim` |
