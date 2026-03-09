# Use Case: UC2 Plan Mode & Content Distinction

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Plan file vs contract distinction | Other tool integrations |
| Plan mode timing | Plan mode UI/UX details |
| Content routing (HOW vs WHAT) | Log format specifications (see UC7) |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Alex, working on a feature request, starts the protocol. Claude enters plan mode and writes methodology to the plan file: "Phase by use case, TDD for implementation." After Alex approves, Claude records the contract with scope and success criteria. Alex likes this separation because the plan file persists across sessions for reference, while the contract captures the immediate scope agreement. Alex can review "what we agreed" (contract) separately from "how we'll do it" (plan file).

## Stakeholders & Interests

- **User:** Plan and contract serve different purposes; confusion breaks workflow
- **LLM:** Needs clear guidance on which content goes where
- **Protocol:** Maintains separation of concerns (HOW vs WHAT)

## Preconditions

- Protocol execution is starting

## Success Guarantee

- Plan file contains HOW (approach, methodology, research strategy)
- Contract event contains WHAT (scope, deliverables, success criteria)
- Plan mode entered before planning begins
- Plan mode exited after approval, before contract publishing

## Minimal Guarantee

- No contract-style content in plan file
- No plan-style content in contract

## Trigger

User starts the protocol for a new task.

## Main Success Scenario

1. User requests a task requiring planning
2. System enters plan mode
3. System writes approach and methodology to plan file
4. System executes plan substeps (investigate, clarify, design)
5. User approves the plan
6. System exits plan mode
7. System records contract with scope and criteria
8. System proceeds to implementation

## Extensions

2a. Plan mode tools not available:
    2a1. System presents plan in conversation instead
    2a2. Continue at step 4 (no plan file created)

3a. System writes contract-style content to plan file:
    3a1. VIOLATION - plan file should contain HOW, not WHAT
    3a2. At step 7, extract scope/deliverables from plan, publish as contract instead

6a. Plan mode tools not available:
    6a1. System notes plan mode not applicable
    6a2. Continue at step 7

7a. System writes plan-style content to contract:
    7a1. VIOLATION - contract should contain WHAT, not HOW

8a. Multi-phase work (plan persists across phases):
    8a1. Plan file retained for reference across phases
    8a2. Each phase gets its own contract

## Technology Variations

- Plan mode may use EnterPlanMode/ExitPlanMode or equivalent
- Contract event format defined by UC7

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Plan file contains scope/deliverables | FAIL: Contract content in plan |
| Contract event contains methodology | FAIL: Plan content in contract |
| Plan mode exited before user approval | FAIL: Premature exit |
| Contract published while plan mode active | FAIL: Should exit first |

## Project Info

- Priority: P1 (High) - High frequency compliance failure
- Frequency: Every protocol execution
