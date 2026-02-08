# Tandem Protocol

**Checkpoints and self-improvement for Claude Code sessions.**

## Why?

Without structure, Claude Code sessions can feel chaotic:
- Plans get forgotten or half-implemented
- No checkpoints to catch issues before they compound
- No way to consistently improve work quality

## What You Get

- **Approval gates** - You decide when to proceed, not Claude
- **Self-grading** - Ask Claude to evaluate and improve its own work
- **Lesson capture** - Claude learns your project's patterns as you work
- **Event logging** - Audit trail of what was agreed and delivered
- **Multi-phase support** - Structure for projects spanning multiple sessions

The `/tandem` command re-activates the protocol when compliance drifts.

## Installation

```bash
# Clone to home directory
cd ~ && git clone https://codeberg.org/binaryphile/tandem-protocol.git

# Create /tandem command
mkdir -p ~/.claude/commands
ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md

# Add to your project's CLAUDE.md
cat >> CLAUDE.md << 'EOF'

# Tandem Protocol
@~/tandem-protocol/README.md

<system-reminder>
**TaskAPI at Gates - INVOKE these tools:**
- Gate 1 approval: Call TaskCreate for each task, then TaskUpdate first to in_progress
- Gate 2 approval: Call TaskUpdate completed for each, then TaskUpdate deleted for each
These are Claude Code tools - invoke them directly, do not just describe the calls.
</system-reminder>
EOF
```

**Verify:** Start Claude Code, then run `/tandem plan to X so Y`

## Usage

### When to use `/tandem`

Invoke 1-2 times early in your session, or whenever you notice protocol drift:

- At session start (before planning): `/tandem make a plan to...`
- When Claude skips steps or you've lost track of the current step

### How it works

The protocol lives in your CLAUDE.md (via @reference), so it's always in context. The `/tandem` command reinforces attention to it when Claude starts drifting.

## The Flow

```mermaid
flowchart LR
    S1[Plan] -->|"GATE 1"| S2[Implement]
    S2 --> S3[Present]
    S3 -->|"GATE 2"| S4[Commit]
    S4 -.->|"next phase"| S1

    style S1 fill:#e8f5e9,stroke:#388e3c
    style S3 fill:#fff3e0,stroke:#ff9800
```

At each gate, you can **approve**, **request a grade**, or **ask for improvements**.

## Example

```
You:    /tandem refactor the payment module into separate services
Claude: [explores codebase, presents plan] May I proceed?
You:    proceed                              <- GATE 1
Claude: [implements] May I proceed?
You:    grade your work
Claude: B+ (87/100) - OrderService still coupled to PaymentGateway
You:    improve
Claude: [extracts interface, re-presents] May I proceed?
You:    proceed                              <- GATE 2
Claude: [commits, sets up next phase]
```

## Learn More

See [FEATURES.md](FEATURES.md) for details on:
- **Self-grading cycles** - Grade and improve work before committing
- **Lesson capture** - Route learnings to guides for future sessions
- **Event logging** - Audit trail with Contract/Completion/Interaction entries
- **PI cognitive stages** - Structured thinking for complex tasks
- **Multi-phase projects** - Maintain coherence across sessions

## Testing

Run `for t in tests/uc*.sh; do bash "$t"; done` to verify protocol compliance patterns.

---

# The Protocol

## Protocol Flow

```mermaid
flowchart TD
    PLAN[Plan Mode] --> EXPLORE[Explore & Design]
    EXPLORE --> ASK[Ask Questions]
    ASK --> G1{GATE 1}
    G1 -->|approve| LOG1[Log Contract]
    LOG1 --> IMPL[Implement]
    IMPL --> PRESENT[Present Results]
    PRESENT --> G2{GATE 2}
    G2 -->|approve| LOG2[Log Completion]
    LOG2 --> COMMIT[Commit]
    COMMIT --> NEXT[Next Phase]
    NEXT --> PLAN

    G1 -->|revise| EXPLORE
    G2 -->|grade| GRADE[Self-Grade]
    G2 -->|improve| IMPROVE[Make Changes]
    GRADE --> PRESENT
    IMPROVE --> PRESENT

    style G1 fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    style G2 fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    style LOG1 fill:#e8f5e9,stroke:#4caf50
    style LOG2 fill:#e8f5e9,stroke:#4caf50
```

## PI Model

| Stage | What Happens | Gate |
|-------|--------------|------|
| **Plan** | Explore, understand, ask questions, design | Gate 1: approve plan |
| **Implement** | Execute, present results | Gate 2: approve results |

**Before Gate 1: MUST verify plan includes TaskAPI and Log instructions at each gate.**

Checklist before requesting approval:
- [ ] "At Gate 1 Approval" section with TaskCreate, TaskUpdate, Log Contract
- [ ] "At Gate 2 Approval" section with TaskUpdate (delete), Log Completion
- [ ] Tasks JSON for TaskCreate calls

Do not request "May I proceed?" without these sections in the plan file.

**GATE 1 ACTIONS** (when user says "proceed"):

1. Log Contract:
```bash
cat >> plan-log.md << 'EOF'
2026-02-08T12:00:00Z | Contract: Phase 1 - objective | [ ] criterion1, [ ] criterion2
EOF
```

2. Use TaskCreate tool for each task:
```json
{"subject": "Task 1", "description": "Details", "activeForm": "Working on task 1"}
{"subject": "Task 2", "description": "Details", "activeForm": "Working on task 2"}
```

3. Use TaskUpdate tool:
```json
{"taskId": "1", "status": "in_progress"}
```

**STOP: Do not implement until Contract logged AND TaskCreate called AND TaskUpdate called.**

**GATE 2 ACTIONS** (when user approves results):

1. Use TaskUpdate tool for each task:
```json
{"taskId": "1", "status": "completed"}
{"taskId": "2", "status": "completed"}
```

2. Log Completion:
```bash
cat >> plan-log.md << 'EOF'
2026-02-08T12:30:00Z | Completion: Phase 1 | [x] criterion1 (evidence), [x] criterion2 (evidence)
EOF
```

3. Use TaskUpdate tool to delete:
```json
{"taskId": "1", "status": "deleted"}
{"taskId": "2", "status": "deleted"}
```

4. Commit:
```bash
git add deliverable.py plan-log.md && git commit -m "Phase 1 complete"
```

## Event Logging

All events logged to `plan-log.md` via append:

**On "grade"** (log immediately, then re-present):
```bash
cat >> plan-log.md << 'EOF'
2026-02-08T12:10:00Z | Interaction: grade -> B+/88, missing edge case
EOF
```

**On "improve"** (log immediately, then make changes):
```bash
cat >> plan-log.md << 'EOF'
2026-02-08T12:15:00Z | Interaction: improve -> added edge case handling
EOF
```

| Entry | When | Format |
|-------|------|--------|
| Contract | Gate 1 approval | `TIMESTAMP \| Contract: Phase N - objective \| [ ] criterion1, [ ] criterion2` |
| Completion | Gate 2 approval | `TIMESTAMP \| Completion: Phase N \| [x] criterion1 (evidence), [x] criterion2 (evidence)` |
| Interaction | Any grade/improve | `TIMESTAMP \| Interaction: [action] -> [outcome]` |
| Lesson | Non-actionable gap during grading | `TIMESTAMP \| Lesson: [title] -> [guide] \| [context]` |

## TaskAPI at Gates

TaskCreate and TaskUpdate are Claude Code tools. Invoke at gates for spinner UI.

| Gate | Required (bash) | Best-effort (TaskAPI) |
|------|-----------------|----------------------|
| Gate 1 | Log Contract | TaskCreate → TaskUpdate in_progress |
| Gate 2 | Log Completion → Commit | TaskUpdate completed → deleted |

**Note:** Bash commands (Log Contract/Completion) are 100% reliable. TaskAPI invocation is variable - Claude may or may not call the tools. Plan file checkboxes provide guaranteed tracking.

## Plan File Template

Plan files live in `~/.claude/plans/`. **Explicit admin instructions at trigger points:**

```markdown
# [Phase Name] Plan

## Objective
[1-2 sentence summary]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Changes
[What files change, with line references]

## Tasks
[Copy to TaskCreate calls after Gate 1 approval]

    [
      {"subject": "Task 1", "description": "...", "activeForm": "Working on task 1"},
      {"subject": "Task 2", "description": "...", "activeForm": "Working on task 2"}
    ]

## At Gate 1 Approval
- Log Contract entry to plan-log.md
- TaskCreate for each task above
- TaskUpdate first task to in_progress
- Telescope: expand Implement children

## At Gate 2 Approval
- Log Completion entry with evidence
- Telescope: delete phase tasks
- Commit deliverable + plan-log.md
- Route lessons to guides

## Verification
[Commands to verify success criteria]
```

## Tasks API Telescoping

Three-level hierarchy: Phase → Stage → Task

| Level | What | When Visible |
|-------|------|--------------|
| Phase | From plan file | Always (future phases as skeletons) |
| Stage | Plan, Implement | Current phase only |
| Task | Deliverables | Current stage only |

**Plan file structure:**
```
[x] Phase 1: Auth middleware        <- collapsed
[ ] Phase 2: Event logging          <- current phase
    [x] Plan                        <- completed stage
    [ ] Implement                   <- current stage (expanded)
        [ ] Add middleware
        [ ] Update tests
[ ] Phase 3: Future work            <- skeleton
```

**Tasks API mirrors current stage only:**
```
[in_progress] Add middleware
[pending] Update tests
```

| Event | Action |
|-------|--------|
| Enter phase | Add Plan/Implement stages to plan file |
| Gate 1 | Mark Plan `[x]`, expand Implement tasks, TaskCreate for each, first `in_progress` |
| Task done | Mark `[x]` in plan, TaskUpdate `completed`, next `in_progress` |
| Gate 2 | Mark Implement `[x]`, collapse phase, TaskUpdate `deleted` for all |

## Protocol Principles

**Two gates, explicit approval:**
- Gate 1: Approve plan before implementation
- Gate 2: Approve results before commit
- Never proceed without "proceed"/"yes"/"approved"

**User controls scope:**
- User MAY defer work to future phases
- Claude MAY NOT unilaterally defer
- Claude MAY suggest deferring by asking

**Feedback loops:**
- "grade" → self-assess, re-present
- "improve" → fix issues, re-present
- Scope changes → return to Plan stage

**Behavioral logging:**
- Contract at Gate 1 (what we agreed)
- Completion at Gate 2 (what we delivered)
- Interaction on any grade/improve cycle

**Plan files guide execution:**
- Include explicit admin instructions at trigger points
- Tasks JSON defined during planning, not improvised
- Telescope tasks as phases complete
