# Use Case: UC7 Event Logging

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol), event store

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Contract events (scope/deliverables) | Automated log analysis |
| Completion events (deliverable done) | Log aggregation tools |
| Interaction events (user feedback, /i /c /g cycles) | |
| Events recorded in event store | |

## System-in-Use Story

> Alex, starting a new phase, sees Claude publish the scope with criteria: "Phase 1 - auth middleware | middleware | tests | docs". As work completes, Claude publishes completion with evidence for each criterion. Alex invokes `/i` to improve. Claude self-assesses, finds a missing edge case, fixes it, and logs the interaction. Alex likes this because criteria verification is explicit — can't claim "3/3 met" without evidence.

## Stakeholders & Interests

- **User:** Wants record of session flow without managing files
- **LLM:** Needs to capture behavioral data for improvement
- **Protocol:** Enables future behavioral analysis via event logging

## Preconditions

- Protocol execution is in progress

## Success Guarantee

- All protocol events recorded
- Event types distinguish scope (contract), progress (completion), and feedback (interaction)

## Minimal Guarantee

- Major events captured

## Trigger

System reaches a protocol milestone: phase start (contract), deliverable done (completion), or user input (interaction).

## Main Success Scenario

1. System reaches a protocol milestone
2. System determines event type (contract, completion, or interaction)
3. System records event
4. System continues protocol execution

## Extensions

3a. Event store unavailable:
    3a1. System reports error to user
    3a2. Continue protocol execution without logging

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase started (Implementation Gate) | Must have contract event with scope |
| Deliverable complete (Completion Gate) | Must have completion event with evidence |
| User feedback given | Must have interaction event with response |
| `/i` cycle occurred | Must show interaction with description of fix |

## Project Info

- Priority: P4 (New feature)
- Frequency: Every protocol execution
