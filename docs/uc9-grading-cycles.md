# Use Case: UC9 Grading Cycles & Task Events

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol), event store

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| `/i` improve cycles at both gates | Automated grading triggers |
| Auto `/i` cycles before presentation | |
| `/c` compliance grading | Grading rubrics or scoring |
| `/g` external review grading | Per-criterion task tracking |
| Task events at gates | |
| Grading loops in state machine diagrams | |

## System-in-Use Story

> Claude finishes implementing and presents results at the Completion Gate. The user types `/i`. Claude self-assesses, finds a missing validation check, fixes it, and logs the interaction. Claude re-presents. The user types `/i` again. Claude finds nothing more. The user types `/c`. Claude grades against the project's Go guide, finds a naming violation, fixes it, and logs. Re-presents. User types `proceed`. Claude executes the Completion Gate actions, closing the task and committing.

## Stakeholders & Interests

- **User:** Wants iterative quality improvement without complex commands
- **LLM:** Needs clear loop structure to know when to self-assess vs wait
- **Orchestrator:** Needs machine-readable task events to detect gate crossings

## Preconditions

- Protocol is at a gate (step 1d or 3b has presented)

## Success Guarantee

- All grading interactions recorded
- Gate task events published

## Minimal Guarantee

- Grading interaction logged even if fix attempt fails

## Trigger

User types `/i`, `/c`, or `/g` at either gate.

Recommended sequence: `/g` (once at entry), then `/i` (repeated), then `/c` (after plateau).

## Main Success Scenario

1. User types `/i` at a gate
2. System records the interaction
3. System self-assesses work, identifies issues
4. System fixes issues
5. System re-presents at the current gate's presentation step (1d or 3b)
6. User repeats or advances the gate

## Extensions

1a. User types `/c` instead of `/i`:
    1a1. System grades against project guides (not just self-assessment)
    1a2. Continue at step 2

1b. User types `/g` instead of `/i`:
    1b1. System applies external review feedback
    1b2. Continue at step 2

1c. User types `/g` but external review already occurred at this gate:
    1c1. System informs user `/g` is once per gate, suggests `/i`

2a. Auto `/i` cycles ran before initial presentation (up to 3):
    2a1. Issues already fixed before user sees results
    2a2. Continue at step 5 (user sees polished result)

3a. Self-assessment finds no issues:
    3a1. System reports no issues found, re-presents unchanged

6a. User advances the gate (accepts plan at Gate 1, or `proceed` at Gate 2):
    6a1. System executes the gate's actions

6b. Gate event recording fails:
    6b1. System reports error to user, does not commit

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| `/i` at either gate | Interaction logged, issues found and fixed, re-present |
| `/c` at either gate | Compliance grade against guides, fix violations |
| `/g` at either gate | External feedback applied |
| `/g` repeated at same gate | Once per gate — suggest `/i` instead |
| Gate advanced after grading | Gate actions executed |
