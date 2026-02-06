# Use Case: UC5 Line Reference Guidance

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Verify line numbers after edits | Specific tooling for verification |
| Guidance to re-check references | Automated line tracking |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, having just edited tandem-protocol.md to add a new section, realizes the line numbers mentioned in the plan have shifted. Before presenting results, Claude re-reads the affected sections to verify line references still point to the right places. The user likes this because stale line numbers in documentation cause confusion. Claude likes the explicit reminder because it's easy to forget that edits shift line numbers downstream.

## Stakeholders & Interests

- **User:** Wants accurate references when reviewing work
- **LLM:** Needs reminder that line numbers drift after edits
- **Protocol:** Maintains documentation accuracy

## Preconditions

- LLM has made edits to a file
- Plan or contract references specific line numbers

## Success Guarantee

- Line references verified after edits
- Stale references updated before presenting results

## Minimal Guarantee

- LLM aware that line numbers may have shifted

## Trigger

LLM completes edits to a file that has line references in plan/contract.

## Main Success Scenario

1. LLM completes edit to file
2. LLM notes that plan/contract references line numbers in that file
3. LLM re-reads relevant sections to verify line numbers
4. LLM updates any stale references before presenting results

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| After edits with line refs | Must verify references still accurate |
| Stale line number found | Must update before presenting |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 3 | After completing edits, verify line references |
| Step 4 | Grade should check for stale references |

## Project Info

- Priority: P3 (Low frequency failure)
- Frequency: When edits affect referenced lines
- Behavioral Goal Impact: Strengthens existing goal (documentation accuracy)
