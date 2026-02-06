# Use Case: UC3 Plan Mode Entry Sequence

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol under Claude Code)
**Secondary Actors:** User, Plan file system

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Standard entry sequence for ALL planning | Plan file format/structure |
| Phased sessions (UC work) | Plan creation details |
| Non-phased sessions (ad-hoc tasks) | Grade/improve cycle mechanics |
| Quoting existing plan verbatim | Manual grading on explicit request |
| Auto-grading analysis then plan | Automatic improvements (user directs) |
| Waiting for user direction | Mid-phase re-entry |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, resuming work on a phased project, enters plan mode. Before doing anything else, Claude reads the existing plan file and quotes it verbatim—no summarizing, no interpreting. Then Claude asks itself: "Do I actually understand this?" and gives an honest grade. Only after that does Claude evaluate "Is this plan sound?" and grade that too. The user sees both grades and the quoted plan. If Claude misunderstood something, the low analysis grade reveals it immediately—before any work begins. The user says "improve analysis" and Claude re-reads, asks questions, tries again. Once understanding is solid, they can address plan quality. Claude likes this sequence because misunderstandings surface before they compound into wasted work.

## Context of Use

When entering planning mode (for any phase or new session), the LLM must:
1. Check for existing plan file
2. If exists: quote verbatim, then auto-grade
3. Wait for user direction before proceeding

This prevents "confident summaries that miss the point" - a common failure mode.

## Scope Clarification

This entry sequence applies when:
- Starting a new session with existing plan
- Transitioning between UC phases (e.g., UC3 → UC4)

Does NOT apply when:
- User has already given explicit direction (e.g., "commit", "continue to UC4")
- Simple operations that don't require plan review

When user explicitly directs an action, exit plan mode and execute directly.

## Stakeholders & Interests

- **User:** Wants to verify Claude understood the plan correctly before work begins
- **LLM:** Needs clear checkpoint to surface misunderstandings early
- **Protocol:** Ensures plan continuity across sessions

## Preconditions

- LLM is entering plan mode (EnterPlanMode tool or equivalent)
- May or may not have existing plan file at `~/.claude/plans/`

## Success Guarantee

- Existing plan quoted verbatim (not summarized, not interpreted)
- Analysis grade provided (understanding of plan)
- Plan grade provided (quality of plan itself)
- User explicitly directs next action

## Minimal Guarantee

- User sees actual plan contents (not LLM's interpretation)
- LLM does not proceed without user direction

## Trigger

LLM enters plan mode for any phase or new session.

## Main Success Scenario

1. LLM begins Step 1 (any phase or non-phased session)
2. LLM enters plan mode (EnterPlanMode if available)
3. LLM checks for existing plan file at `~/.claude/plans/`
4. LLM finds existing plan
5. LLM quotes plan verbatim (no summarizing, no interpreting)
6. LLM grades own analysis FIRST: "Do I understand this?" (/a)
7. LLM grades plan quality SECOND: "Is this sound?" (/p)
8. LLM presents understanding + "Upon approval I will..." + "May I proceed?"
9. LLM waits for user direction (BLOCKING - cannot proceed without)
10. User directs: "improve" / "proceed"

## Extensions

3a. No existing plan file:
    3a1. LLM notes "No existing plan found"
    3a2. LLM proceeds to create new plan
    3a3. Skip to step 8 (present understanding)

4a. Plan file too large to quote fully:
    4a1. LLM quotes relevant sections for current phase
    4a2. LLM notes which sections were excerpted
    4a3. Continue at step 5

6a. Analysis grade is low (C or below):
    6a1. LLM explicitly lists points of confusion
    6a2. User may clarify before proceeding

7a. Plan grade is low (C or below):
    7a1. LLM explicitly lists plan weaknesses
    7a2. User may choose to improve before work

10a. User says "improve":
    10a1. LLM addresses ALL actionable deductions (analysis + plan)
    10a2. Re-grade both
    10a3. Return to step 8 (present understanding)

10b. User says "proceed":
    10b1. LLM exits plan mode
    10b2. LLM logs Contract entry to plan-log.md (Step 1d)
         Format: `YYYY-MM-DDTHH:MM:SSZ | Contract: [phase] | [ ] criterion1, [ ] criterion2, ...`
    10b3. LLM logs Completion entry for Step 1 (Step 1e)
    10b4. LLM proceeds to Step 2 (complete deliverable)

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Existing plan found | Must quote verbatim, not summarize |
| After quoting plan | Must provide /a grade FIRST (analysis) |
| After /a grade | Must provide /p grade SECOND (plan quality) |
| Order violation | FAIL if /p grade appears before /a grade |
| After both grades | Must wait for user direction (BLOCKING) |
| User hasn't directed | Must NOT proceed to phase work |
| Summarized instead of quoted | FAIL - defeats purpose of surfacing misunderstandings |

## File Content Guide

| Content Type | Belongs In | Example |
|--------------|------------|---------|
| Plan contents | Verbatim quote block | "```\n[exact plan text]\n```" |
| Analysis grade | After quote | "Analysis Grade: B+ (85/100)" |
| Plan grade | After analysis | "Plan Grade: A- (92/100)" |
| Direction prompt | After grades | "Improve or proceed?" |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 1 (start) | Enter plan mode |
| Step 1 (plan mode entry) | Quote plan → /a → /p → present → wait for direction |
| Step 1d | On approval: log Contract entry to plan-log.md |
| Step 1e | Log Completion entry, proceed to Step 2 |
| Any phase start | Re-enter Step 1, trigger this behavior |


## Project Info

- Priority: P2 (Medium) - Prevents "confident but wrong" summaries
- Frequency: Every session start, every phase transition
- Behavioral Goal Impact: Strengthens existing goal (plan presented before implementation)
