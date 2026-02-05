# Tandem Protocol: Enhancement Notes

**Date:** 2026-01-18
**Context:** Observations from Phase 7-8 of sofdevsim-2026 project

---

## Observed Compliance Failures

| Failure | Root Cause | Frequency |
|---------|------------|-----------|
| Skipped Step 1b (questions) | Put questions IN plan, then removed them | High |
| Step 1a informal | No template - unclear what "present understanding" means | Medium |
| Conflated plan file with contract | Claude Code plan mode creates a "plan" - confused with Tandem "contract" | High |
| Archived condensed version | No explicit "verbatim copy" instruction | Low |
| Line numbers drift | Sequential edits invalidate references | Low |

---

## Potential Enhancements

### 1. Step 1a Template

**Current:** "Present understanding to user"

**Proposed:** Add explicit template:
```
I understand the task as: [1-2 sentence summary]
Target files: [paths]
Approach: [brief method]
```

This makes Step 1a concrete and verifiable.

---

### 2. Step 1b Sequencing Rule

**Current:** "Ask clarifying questions"

**Proposed:** Add explicit sequencing note:
```
IMPORTANT: Questions must be ASKED to the user (via conversation or AskUserQuestion tool),
not written into the plan. The plan should reflect ANSWERS, not open questions.
```

This prevents the anti-pattern of embedding questions in artifacts.

---

### 3. Tool Integration Section

**Current:** Protocol assumes generic filesystem

**Proposed:** Add appendix for tool-specific workflows:
```
## Claude Code Integration

- Claude Code "plan mode" creates a PLAN FILE (implementation approach)
- Tandem "contract" is a separate artifact (delivery agreement)
- Relationship: Plan file informs contract content, but they serve different purposes
- Workflow: Exit plan mode → Step 0 → Create contract from plan insights
```

---

### 4. Archive Verbatim Rule

**Current:** "Archive to plan-log.md"

**Proposed:** Add explicit instruction:
```
Archive the COMPLETE contract file verbatim. Do not condense or summarize.
The archive is the historical record - it must match what was agreed to.
```

---

### 5. Line Reference Guidance

**Current:** No guidance on referencing locations in deliverables

**Proposed:** Add note:
```
When referencing line numbers in contracts:
- Verify line numbers AFTER all edits complete (not during)
- Use grep/search to confirm before finalizing Step 3
- Alternatively, use content anchors ("after the UC11 section") instead of line numbers
```

---

## Summary of Proposed Changes

| Section | Change Type | Rationale |
|---------|-------------|-----------|
| Step 1a | Add template | Makes "present understanding" concrete |
| Step 1b | Add sequencing note | Prevents questions-in-plan anti-pattern |
| New appendix | Tool integration | Addresses Claude Code/Cursor confusion |
| Step 1e/5b | Verbatim rule | Ensures archive integrity |
| Step 3 | Line reference guidance | Handles edit-induced drift |

---

## Priority Ranking

| Enhancement | Impact | Effort | Priority |
|-------------|--------|--------|----------|
| Step 1b sequencing rule | High (most common failure) | Low (one paragraph) | **P1** |
| Tool integration appendix | High (Claude Code confusion) | Medium (new section) | **P1** |
| Step 1a template | Medium (vague but functional) | Low (add template) | **P2** |
| Verbatim archive rule | Low (rare failure) | Low (one sentence) | **P3** |
| Line reference guidance | Low (minor issue) | Low (add note) | **P3** |

**Recommendation:** Implement P1 items first. They address the two most frequent failures observed.

---

## Trade-offs

| Enhancement | Benefit | Cost |
|-------------|---------|------|
| Step 1a template | Concrete, verifiable | Slightly more rigid; may not fit all contexts |
| Step 1b sequencing | Prevents question-embedding | Requires tool access (AskUserQuestion) or explicit pause |
| Tool integration | Clarifies plan vs contract | Adds complexity; may not apply to all tools |
| Verbatim archives | Complete historical record | Larger plan-log.md files |
| Line references | Accurate traceability | Extra verification step; content anchors may be fragile too |

---

## Validation Approach

### Metrics to Track

| Metric | How to Measure | Target |
|--------|----------------|--------|
| Step 1b compliance | Did agent ASK questions before plan? | 100% |
| Plan/contract confusion | Did agent conflate plan file with contract? | 0 occurrences |
| Archive completeness | Is archived contract verbatim? | 100% |
| Overall Tandem grade | Self-assessed grade per phase | ≥ A- (90%) |

### Validation Process

1. Adopt P1 enhancements in protocol
2. Execute 3-5 phases with enhanced protocol
3. Track compliance grades and failure types
4. Compare to Phase 7-8 baseline (D→A- trajectory)
5. Adjust or promote P2/P3 based on observed impact

---

## Characterization of Tandem Requirements

### Core Structure: Two Checkpoints + Three Rules

**Two Checkpoints:**
1. **Before** (Step 1d): "Here's what I plan to do" → Approve → Archive
2. **After** (Step 4b): "Here's what I did" → Approve → Archive + Commit

**Three Rules:**
1. **Single-phase scope**: One contract = one deliverable. Never plan Phase N+1 while executing Phase N.
2. **Blocking gates**: Steps 1b, 1d, 4b require explicit user response. Cannot proceed without.
3. **Change = restart**: Feedback that alters scope → return to Step 1, not iterate at Step 4.

### Anti-Patterns Tandem Prevents

| Anti-Pattern | How Tandem Prevents |
|--------------|---------------------|
| "Just one more thing" | Single-phase scope - new work = new contract |
| Scope creep mid-execution | Change = restart at Step 1 |
| Forgotten context | Contracts + archives preserve agreements |
| Skipped approval | Blocking gates at 1d and 4b |
| "I thought you wanted..." | Step 1b forces clarifying questions |
| Lost work history | Step 5b archives before deleting contract |
