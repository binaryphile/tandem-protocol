# Use Case: UC4 Verbatim Archive Rule

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** File system (plan-log.md)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Archive = literally append file | Entry format specification (see design doc) |
| Intro line before content | Plan-log organization |
| Three entry types (Plan, Contract, Completion) | Entry type definitions (see design doc) |
| Checkbox update before archive | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, completing a phase of work, needs to archive the contract to plan-log.md. Instead of summarizing what happened or reformatting the contract, Claude first updates all contract checkboxes to reflect completion, then writes a grep-friendly intro line (`2026-02-05T14:30:00Z | Completion: UC3-C`), then literally appends the contract file contents. No editing, no interpretation—just cat the file. The user likes this because when they review the log later, they see exactly what was agreed, not Claude's summary of it. Claude likes it because there's no judgment call about what to include—just append everything.

## Stakeholders & Interests

- **User:** Wants exact record of what was agreed, not interpretation
- **LLM:** Needs simple, unambiguous rule (no judgment about what to summarize)
- **Protocol:** Ensures audit trail integrity for behavioral analysis

## Preconditions

- Contract file exists with APPROVED status
- plan-log.md exists

## Success Guarantee

- Contract appended to plan-log.md exactly as written
- Intro line with date and subject precedes content
- Original contract file deleted after archive

## Minimal Guarantee

- Contract content preserved somewhere (even if format wrong)

## Trigger

LLM reaches Step 4b (archive completed contract) or equivalent checkpoint.

## Main Success Scenario

1. LLM completes work and marks contract APPROVED
2. LLM updates all contract checkboxes to reflect completion state
3. LLM writes intro line to plan-log.md (see design doc for format)
4. LLM appends contract file contents verbatim
5. LLM deletes original contract file

## Extensions

4a. Contract contains sensitive data:
    4a1. LLM notes sensitivity but still archives verbatim
    4a2. User responsibility to sanitize before archiving if needed

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Archive requested | Must append file literally, not summarize |
| Checkboxes | Must be updated before archive |
| Intro line | Must be grep-friendly format (see design doc) |
| After archive | Original contract file must be deleted |
| Content transformation | FAIL if any editing/summarizing detected |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 4b | Archive contract verbatim (not summarize) |
| Step 1e | Archive plan + contract (same rule applies) |

## Project Info

- Priority: P3 (Low frequency failure)
- Frequency: Every phase completion
- Behavioral Goal Impact: Strengthens existing goal (archive integrity)
