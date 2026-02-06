# Use Case: UC7 Interaction Logging

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** plan-log.md (log target)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Logging g/i cycles in contract | Log format standardization |
| Recording user feedback | Automated log analysis |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, completing a feature implementation, updates the contract with an interaction log showing: "User said 'proceed' → started implementation → /q revealed missing post-approval steps → user feedback 'do post acceptance steps' → completed properly." When the contract is archived, this log goes with it. The user likes this because they can review how the session unfolded. Claude likes it because patterns emerge over time—which feedback is common, where compliance gaps appear.

## Stakeholders & Interests

- **User:** Wants record of session flow for review
- **LLM:** Needs to capture behavioral data for improvement
- **Protocol:** Enables future behavioral analysis

## Preconditions

- Contract file exists
- LLM is executing protocol steps

## Success Guarantee

- Key interactions logged in contract
- Logs archived with contract to plan-log.md
- Patterns visible for future analysis

## Minimal Guarantee

- Major user feedback captured somewhere

## Trigger

LLM receives user input during protocol execution (proceed, /q, /w, /i, feedback).

## Main Success Scenario

1. LLM receives user input
2. LLM records input type and outcome in contract's Interaction section
3. LLM continues protocol execution
4. At archive, interactions preserved in plan-log.md

## Extensions

2a. No contract exists yet:
    2a1. Note interaction in session, include when contract created
    2a2. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Contract archived | Must contain Interaction section |
| User feedback given | Must be logged |
| g/i cycle occurred | Must show grade → improve → outcome |

## Interaction Types to Log

| Type | Example | Log Format |
|------|---------|------------|
| Gate response | "proceed" | `proceed → [action taken]` |
| Skill invocation | /w, /q, /i | `/w → [grade given]` |
| User feedback | "do post acceptance steps" | `feedback: [quote] → [response]` |
| Direction change | "stop", "skip" | `direction: [quote] → [outcome]` |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 3 | Update contract with interactions before self-assessment |
| Step 4b | Archive includes interaction log |

## Project Info

- Priority: P4 (New feature)
- Frequency: Every protocol execution
- Behavioral Goal Impact: +1 new goal (interactions logged for analysis)
