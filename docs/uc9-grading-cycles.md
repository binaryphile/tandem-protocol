# Use Case: UC9 Grading Cycles & Task Events

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** plan-log.md (log target), Era streams (task events via mk)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| `/i` improve cycles at both gates | Automated grading triggers |
| `/c` compliance grading | Grading rubrics or scoring |
| `/g` external review grading | Per-criterion task tracking |
| Task events via mk at gates | Interaction events in Era streams |
| Grading loops in state machine diagrams | |

## System-in-Use Story

> Claude finishes implementing and presents results at the Completion Gate. The user types `/i`. Claude self-assesses, finds a missing validation check, fixes it, and logs: `Interaction: /i -> missing validation, added`. Claude re-presents. The user types `/i` again. Claude finds nothing more. The user types `/c`. Claude grades against the project's Go guide, finds a naming violation, fixes it, and logs. Re-presents. User types `proceed`. Claude executes the Completion Gate bash block, which runs `mk done <task-id>` to close the task in the Era stream, then commits.

## Stakeholders & Interests

- **User:** Wants iterative quality improvement without complex commands
- **LLM:** Needs clear loop structure to know when to self-assess vs wait
- **Orchestrator:** Needs machine-readable task events (mk task/done) to detect gate crossings

## Preconditions

- Protocol is at a gate (step 1d or 3b has presented)
- plan-log.md exists
- mk script available with PROJECT_ROOT set

## Success Guarantee

- Grading cycles visible as first-class states in all protocol diagrams
- `/i`, `/c`, `/g` documented with bash blocks for plan-log entries
- Gate events published as task/task-done via mk (not direct era publish)

## Minimal Guarantee

- Grading cycles documented in gate sections

## Trigger

User types `/i`, `/c`, or `/g` at either gate.

## Main Success Scenario

1. User types `/i` at a gate
2. LLM logs Interaction entry to plan-log.md
3. LLM self-assesses work, identifies issues
4. LLM fixes issues
5. LLM re-presents at step 3b
6. User repeats or types `proceed`

## Extensions

1a. User types `/c` instead of `/i`:
    1a1. LLM grades against project guides (not just self-assessment)
    1a2. Continue at step 2

1b. User types `/g` instead of `/i`:
    1b1. LLM applies external review feedback
    1b2. Continue at step 2

6a. User types `proceed`:
    6a1. LLM executes Completion Gate bash block (mk done, commit)

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| `/i` at either gate | Interaction logged, issues found and fixed, re-present |
| `/c` at either gate | Compliance grade against guides, fix violations |
| `/g` at either gate | External feedback applied |
| `proceed` after grading | Gate bash block executed |

## Event Types

| Event | Source | Destination | Format |
|-------|--------|-------------|--------|
| Interaction | `/i` `/c` `/g` at either gate | plan-log.md | `YYYY-MM-DDTHH:MM:SSZ \| Interaction: /i -> description` |
| Task | Implementation Gate | Era stream via `mk task` | task event with description |
| Task-done | Completion Gate | Era stream via `mk done` | task-done event with refs |
