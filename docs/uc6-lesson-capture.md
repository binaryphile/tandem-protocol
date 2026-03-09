# Use Case: UC6 Lesson Capture from Grading

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol), guide files

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Capturing non-actionable lessons during grading | Guide file format/structure |
| Routing lessons to appropriate guide | Automated lesson extraction |
| Distinguishing deductions from lessons | |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Alex, reviewing Claude's grade on a feature implementation, notices Claude identified a gap: "The error messages could be more user-friendly." This isn't fixable now — the feature works, the contract is complete. Instead of inflating the grade deduction or ignoring it, Claude notes the lesson in the appropriate guide for future reference. Alex likes this because insights aren't lost. The grade stays focused on actionable items while patterns still get captured for future work.

## Stakeholders & Interests

- **User:** Wants insights preserved without grade inflation
- **LLM:** Needs clear rule for what's a deduction vs. a lesson
- **Protocol:** Maintains grading accuracy while enabling improvement

## Preconditions

- System is performing grading at a gate
- Gap identified that isn't actionable in current session

## Success Guarantee

- Actionable gaps become grade deductions
- Non-actionable gaps become lessons in guides
- No grade inflation from non-actionable items
- Lessons preserved for future reference

## Minimal Guarantee

- Clear distinction attempted between deduction and lesson
- No lessons silently dropped

## Trigger

System identifies a gap during grading that cannot be fixed in the current session.

## Main Success Scenario

1. System performs grading on completed work
2. System identifies gap in deliverable
3. System applies actionability test: "Can I fix this now?"
4. Gap is NOT actionable (out of scope, future work, process improvement)
5. System captures lesson in appropriate guide
6. System continues grading without deducting for this gap

## Extensions

3a. Gap IS actionable:
    3a1. System includes as grade deduction
    3a2. If user says "improve", system fixes it
    3a3. Continue at step 2 for next gap

5a. No appropriate guide exists:
    5a1. System notes lesson in grading output
    5a2. Suggests guide creation if pattern recurring
    5a3. Continue at step 6

5b. Lesson duplicates existing guide content:
    5b1. System notes "already captured"
    5b2. Continue at step 6

## Guard Conditions

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

## Project Info

- Priority: P4 (New feature)
- Frequency: Every grading cycle
