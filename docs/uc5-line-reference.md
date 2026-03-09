# Use Case: UC5 Line Reference Guidance

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Verify line numbers after edits | Specific tooling for verification |
| Guidance to re-check references | Automated line tracking |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Alex, reviewing Claude's implementation results, notices the plan references line 45 of auth.go — but Claude just added 20 lines above that section. Before presenting, Claude re-reads the affected sections to verify line references still point to the right places. Alex likes this because stale line numbers in documentation cause confusion.

## Stakeholders & Interests

- **User:** Wants accurate references when reviewing work
- **LLM:** Needs reminder that line numbers drift after edits
- **Protocol:** Maintains documentation accuracy

## Preconditions

- System has made edits to a file
- Plan or contract references specific line numbers

## Success Guarantee

- Line references verified after edits
- Stale references updated before presenting results

## Minimal Guarantee

- System aware that line numbers may have shifted

## Trigger

System completes edits to a file that has line references in plan or contract.

## Main Success Scenario

1. System completes edits to a file
2. System notes that plan or contract references line numbers in that file
3. System re-reads relevant sections to verify line numbers
4. System updates any stale references before presenting results

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| After edits with line refs | Must verify references still accurate |
| Stale line number found | Must update before presenting |

## Project Info

- Priority: P3 (Low frequency failure)
- Frequency: When edits affect referenced lines
