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
| Interaction entries (user feedback, g/i cycles) | Exceptional cases (Claude reasons through) |
| Direct logging to plan-log.md | Contract file lifecycle |

## System-in-Use Story

> Claude, starting a new phase, logs the scope: `2026-02-06T14:30:00Z | Contract: Phase 1 - implement auth middleware`. As work progresses, Claude logs completions: `2026-02-06T14:45:00Z | Completion: Step 2 - auth.go created, 45 lines`. The user invokes `/p` to grade the plan. Claude grades B/84 and logs: `2026-02-06T14:50:00Z | Interaction: /p grade → B/84, missing edge case`. User says `/i`, Claude improves and logs: `2026-02-06T14:52:00Z | Interaction: /i improve → added edge case handling`. The user likes this because everything is captured in real-time—no contract file to manage. Claude likes it because patterns are immediately visible in the single log file.

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
| g/i cycle occurred | Must show grade → improve → outcome |

## Event Types

| Type | When | Format |
|------|------|--------|
| Contract | Phase start (Step 1d) | `YYYY-MM-DDTHH:MM:SSZ \| Contract: [phase] - [scope summary]` |
| Completion | Step/deliverable done | `YYYY-MM-DDTHH:MM:SSZ \| Completion: [step] - [result]` |
| Interaction | User input (feedback, skills) | `YYYY-MM-DDTHH:MM:SSZ \| Interaction: [input] → [response]` |

## Integration Points

| Protocol Step | Event Type | Example |
|---------------|------------|---------|
| Step 1d | Contract | `Contract: Phase 1 - implement X, 3 success criteria` |
| Step 1e | Completion | `Completion: Step 1 - plan validated, approval received` |
| Step 2 | Completion | `Completion: Step 2 - deliverable created` |
| Step 4b | Interaction | `Interaction: /w grade → A-/91` |
| Step 5 | Completion | `Completion: Phase 1 approved` |

## Project Info

- Priority: P4 (New feature)
- Frequency: Every protocol execution
- Behavioral Goal Impact: +1 new goal (events logged for analysis)
