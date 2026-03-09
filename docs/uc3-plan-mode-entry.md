# Use Case: UC3 Plan Mode Entry Sequence

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Standard entry sequence for ALL planning | Plan file format/structure |
| Phased sessions (UC work) | Plan creation details |
| Non-phased sessions (ad-hoc tasks) | Grade/improve cycle mechanics |
| Quoting existing plan verbatim | Manual grading on explicit request |
| Auto-grading analysis then plan | Automatic improvements (user directs) |
| Waiting for user direction | Mid-phase re-entry |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Alex, resuming work on a phased project, starts the protocol. Before doing anything else, Claude reads the existing plan and quotes it verbatim — no summarizing, no interpreting. Then Claude asks itself: "Do I actually understand this?" and gives an honest grade. Only after that does Claude evaluate "Is this plan sound?" The user sees both grades and the quoted plan. If Claude misunderstood something, the low analysis grade reveals it immediately — before any work begins. Alex says "improve analysis" and Claude re-reads, asks questions, tries again. Once understanding is solid, they can address plan quality.

## Stakeholders & Interests

- **User:** Wants to verify Claude understood the plan correctly before work begins
- **LLM:** Needs clear checkpoint to surface misunderstandings early
- **Protocol:** Ensures plan continuity across sessions

## Preconditions

- Protocol is entering the Plan stage

## Success Guarantee

- Existing plan quoted verbatim (not summarized, not interpreted)
- Analysis grade provided (understanding of plan)
- Plan grade provided (quality of plan itself)
- User explicitly directs next action

## Minimal Guarantee

- User sees actual plan contents (not system's interpretation)
- System does not proceed without user direction

## Trigger

User starts the protocol for a task (new or continuing).

## Main Success Scenario

1. User initiates planning
2. System enters plan mode
3. System checks for existing plan
4. System finds existing plan
5. System quotes plan verbatim (no summarizing, no interpreting)
6. System grades own analysis: "Do I understand this?"
7. System grades plan quality: "Is this sound?"
8. System presents understanding and asks for direction
9. User directs: "improve" or "proceed"

## Extensions

3a. No existing plan:
    3a1. System notes "No existing plan found"
    3a2. System proceeds to create new plan
    3a3. Skip to step 8 (present for approval)

4a. Plan too large to quote fully:
    4a1. System quotes relevant sections for current phase
    4a2. System notes which sections were excerpted
    4a3. Continue at step 5

6a. Analysis grade is low:
    6a1. System explicitly lists points of confusion
    6a2. User may clarify before proceeding

7a. Plan grade is low:
    7a1. System explicitly lists plan weaknesses
    7a2. User may choose to improve before work

9a. User says "improve":
    9a1. System addresses all actionable deductions
    9a2. Re-grades both
    9a3. Return to step 8

9b. User says "proceed":
    9b1. System exits plan mode
    9b2. System records the agreed scope and criteria
    9b3. System proceeds to implementation

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Existing plan found | Must quote verbatim, not summarize |
| After quoting plan | Must provide analysis grade FIRST |
| After analysis grade | Must provide plan quality grade SECOND |
| Order violation | FAIL if plan grade appears before analysis grade |
| After both grades | Must wait for user direction (BLOCKING) |
| User hasn't directed | Must NOT proceed to implementation |
| Summarized instead of quoted | FAIL - defeats purpose of surfacing misunderstandings |

## Project Info

- Priority: P2 (Medium) - Prevents "confident but wrong" summaries
- Frequency: Every session start, every phase transition
