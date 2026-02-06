# Use Case: UC4 Verbatim Archive Rule

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** File system (plan-log.md)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Archive = literally append file | Archive format/structure |
| Intro line before content | Plan-log organization |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, completing a phase of work, needs to archive the contract to plan-log.md. Instead of summarizing what happened or reformatting the contract, Claude writes an intro line with the date and subject, then literally appends the contract file contents. No editing, no interpretation—just cat the file. The user likes this because when they review the log later, they see exactly what was agreed, not Claude's summary of it. Claude likes it because there's no judgment call about what to include—just append everything.

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

LLM reaches Step 6b (archive completed contract) or equivalent checkpoint.

## Main Success Scenario

1. LLM completes work and marks contract APPROVED
2. LLM writes intro line to plan-log.md: `## [Subject] Contract: Archived Verbatim [Date]`
3. LLM appends contract file contents literally (cat >> plan-log)
4. LLM deletes original contract file

## Extensions

3a. Contract contains sensitive data:
    3a1. LLM notes sensitivity but still archives verbatim
    3a2. User responsibility to sanitize before archiving if needed

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Archive requested | Must append file literally, not summarize |
| Intro line | Must include date and subject |
| After archive | Original contract file must be deleted |
| Content transformation | FAIL if any editing/summarizing detected |

## File Content Guide

| Content Type | Belongs In | Example |
|--------------|------------|---------|
| Intro line | Before contract | `## UC3-C Contract: Archived Verbatim 2026-02-05` |
| Contract body | After intro | Exact file contents, no transformation |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 6b | Archive contract verbatim (not summarize) |
| Step 2e | Archive plan + contract (same rule applies) |

## Project Info

- Priority: P3 (Low frequency failure)
- Frequency: Every phase completion
- Behavioral Goal Impact: Strengthens existing goal (archive integrity)
