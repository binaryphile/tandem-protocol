# Use Case: UC7 Event Logging

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** plan-log.md (log target)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Contract entries (scope/deliverables) | Automated log analysis |
| Completion entries (step/deliverable done) | Log aggregation tools |
| Interaction entries (user feedback, /i /c /g cycles) | Exceptional cases (Claude reasons through) |
| Direct logging to plan-log.md | Contract file lifecycle |

## System-in-Use Story

> Claude, starting a new phase, logs the scope with checkboxes: `2026-02-06T14:30:00Z | Contract: Phase 1 - auth middleware | [ ] middleware, [ ] tests, [ ] docs`. As work completes, Claude copies the criteria and fills checkboxes: `2026-02-06T14:45:00Z | Completion: Step 2 | [x] middleware (auth.go:45), [x] tests (auth_test.go), [x] docs (README:12)`. The user invokes `/i` to improve. Claude self-assesses, finds a missing edge case, and fixes it, logging: `2026-02-06T14:50:00Z | Interaction: /i -> missing edge case, added handling`. The user likes this because criteria verification is explicit—can't claim "3/3 met" without evidence. Claude likes it because the checkbox format enforces accountability.

## Stakeholders & Interests

- **User:** Wants record of session flow without managing contract files
- **LLM:** Needs to capture behavioral data for improvement
- **Protocol:** Enables future behavioral analysis via single log file

## Preconditions

- plan-log.md exists or will be created
- LLM is executing protocol steps

## Success Guarantee

- All protocol events logged directly to plan-log.md
- Entry types distinguish scope (Contract), progress (Completion), and feedback (Interaction)
- Patterns visible for future analysis

## Minimal Guarantee

- Major events captured in plan-log.md

## Trigger

LLM reaches a logging point: phase start (Contract), step completion (Completion), or user input (Interaction).

## Main Success Scenario

1. LLM reaches logging point during protocol execution
2. LLM determines entry type (Contract, Completion, or Interaction)
3. LLM appends timestamped entry to plan-log.md
4. LLM continues protocol execution

## Extensions

3a. plan-log.md doesn't exist:
    3a1. Create plan-log.md with header
    3a2. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase started | Must have Contract entry with scope |
| Step completed | Must have Completion entry with result |
| User feedback given | Must have Interaction entry with response |
| /i cycle occurred | Must show /i -> description of fix |

## Event Types

| Type | When | Format |
|------|------|--------|
| Contract | Phase start (Step 1d) | `YYYY-MM-DDTHH:MM:SSZ \| Contract: [phase] \| [ ] criterion1, [ ] criterion2, ...` |
| Completion | Step/deliverable done | `YYYY-MM-DDTHH:MM:SSZ \| Completion: [step] \| [x] criterion1 (evidence), [x] criterion2 (evidence), ...` |
| Interaction | User input (feedback, skills) | `YYYY-MM-DDTHH:MM:SSZ \| Interaction: [input] -> [response]` |

**Completion markers:**
- `[x]` = completed with evidence
- `[ ]` = not completed (failure)
- `[-]` = removed (with reason)
- `[+]` = added (with reason)

## Integration Points

| Protocol Step | Event Type | Example |
|---------------|------------|---------|
| Step 1d | Contract | `Contract: Phase 1 - auth \| [ ] middleware, [ ] tests, [ ] docs` |
| Step 1e | Completion | `Completion: Step 1 - plan validated` |
| Step 2b | Completion | `Completion: Step 2 \| [x] middleware (auth.go:45), [x] tests (pass), [x] docs (README)` |
| Step 3a | Presentation | "Upon your approval" lists Step 4a/4b/4c explicitly |
| Step 3b | Interaction | `Interaction: /i -> found issue, fixed` |
| Step 4a | Completion | `Completion: Phase 1 approved` |
| Step 4b | Commit | Commit deliverable + plan-log.md |
| Step 4c | Transition | Groom plan file, route lessons, setup next phase |

## Project Info

- Priority: P4 (New feature)
- Frequency: Every protocol execution
- Behavioral Goal Impact: +1 new goal (events logged for analysis)
