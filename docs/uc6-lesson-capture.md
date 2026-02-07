# Use Case: UC6 Lesson Capture from Grading

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** Guide files (self-grading-guide.md, etc.)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Capturing non-actionable lessons during grading | Guide file format/structure |
| Routing lessons to appropriate guide | Automated lesson extraction |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, grading its work on a feature implementation, identifies a gap: "The error messages could be more user-friendly." This isn't fixable now—the feature works, the contract is complete. Instead of inflating the grade deduction or ignoring it, Claude notes the lesson in self-grading-guide.md: "Consider user-facing error message clarity during implementation." The user likes this because insights aren't lost. Claude likes it because the grade stays focused on actionable items while patterns still get captured for future work.

## Stakeholders & Interests

- **User:** Wants insights preserved without grade inflation
- **LLM:** Needs clear rule for what's a deduction vs. a lesson
- **Protocol:** Maintains grading accuracy while enabling improvement

## Preconditions

- LLM is performing grading (Step 4b or any /w invocation)
- Gap identified that isn't actionable in current session

## Success Guarantee

- Actionable gaps → grade deductions
- Non-actionable gaps → lessons in guides
- No grade inflation from non-actionable items
- Lessons preserved for future reference

## Minimal Guarantee

- Clear distinction attempted between deduction and lesson
- No lessons silently dropped

## Trigger

LLM identifies a gap during grading that cannot be fixed in the current session.

## Main Success Scenario

1. LLM performs grading on completed work
2. LLM identifies gap in deliverable
3. LLM applies actionability test: "Can I fix this now?"
4. Gap is NOT actionable (out of scope, future work, process improvement)
5. LLM captures lesson in appropriate guide file
6. LLM continues grading without deducting for this gap

## Extensions

3a. Gap IS actionable:
    3a1. LLM includes as grade deduction
    3a2. If user says "improve", LLM fixes it
    3a3. Continue at step 2 for next gap

5a. No appropriate guide exists:
    5a1. LLM notes lesson in grading output
    5a2. Suggests guide creation if pattern recurring
    5a3. Continue at step 6

5b. Lesson duplicates existing guide content:
    5b1. LLM notes "already captured"
    5b2. Continue at step 6

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Non-actionable gap found | Must route to guide, not grade |
| Actionable gap found | Must include in grade deductions |
| Grade contains non-actionable items | FAIL: Grade inflation |
| Lesson identified but not captured | FAIL: Insight lost |

## Actionability Test

**"Can I fix this now?"** means ALL of:
- Within current contract scope
- Fixable in this session
- Not requiring user decisions not yet made
- Not a process/methodology improvement (those go to guides)

## File Routing Guide

Route lessons to the PI stage where they apply:

| Lesson Type | PI Stage | Target Guide |
|-------------|----------|--------------|
| "Should have explored X" | Plan | planning-guide.md |
| "Misunderstood Y" | Plan | planning-guide.md |
| "Better approach Z" | Plan | planning-guide.md |
| Code quality patterns | Implement | (domain-specific guide) |
| Protocol compliance | (meta) | protocol-guide.md |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 3b | During grading, apply actionability test |
| Any /w | Same rule applies to ad-hoc grading |
| Step 4 | Route non-actionable lessons to stage guides |

## Project Info

- Priority: P4 (New feature)
- Frequency: Every grading cycle
- Behavioral Goal Impact: +1 new goal (lessons captured in guides)
