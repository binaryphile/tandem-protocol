# Use Case: UC9 IAPI Stage Model

**Scope:** Tandem Protocol
**Level:** White (strategic - spans multiple user sessions)
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** Guide files (investigation-guide.md, analysis-guide.md, planning-guide.md, domain guides)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Four orthogonal stages: Investigate, Analyze, Plan, Implement | Stage guide implementation details |
| Stage-specific guide loading | Guide file format |
| Lesson routing to stage guides | Automated lesson extraction |
| Plan file locality for task management | Guide grooming/pruning |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Claude, starting a new feature request, enters the Investigation stage. The investigation guide loads with accumulated lessons from past investigations ("check for existing patterns before proposing new ones", "verify dependencies early"). Claude explores the codebase, then transitions to Analysis. The analysis guide loads with its own lessons ("grade understanding before proceeding", "identify assumptions explicitly"). After analysis confirms understanding, Claude enters Planning with planning-specific lessons. Finally, Implementation begins with implementation lessons loaded. When grading reveals a non-actionable deduction like "should have checked for race conditions during investigation", that lesson routes to the investigation guide—improving future investigations without penalizing the current grade.

## Stakeholders & Interests

- **User:** Wants Claude to get better at each stage over time
- **LLM:** Needs stage-appropriate guidance loaded at the right time
- **Protocol:** Enables incremental improvement through lesson accumulation

## The Four Stages

| Stage | Focus | Key Question | Output |
|-------|-------|--------------|--------|
| **I**nvestigate | Explore context | "What exists?" | Patterns identified, context gathered |
| **A**nalyze | Grade understanding | "Do I understand?" | Confidence level, clarifying questions |
| **P**lan | Design approach | "How should we do this?" | Approved plan with success criteria |
| **I**mplement | Execute work | "Build it right" | Deliverable meeting criteria |

## Main Success Scenario

1. LLM enters Investigation stage (subagent), reads investigation-guide.md
2. Subagent explores codebase, returns structured output with Lessons Applied/Missed
3. LLM enters Analysis stage (subagent), reads analysis-guide.md
4. Subagent grades understanding, identifies gaps/assumptions
5. LLM enters Planning stage (subagent), reads planning-guide.md
6. Subagent finalizes approach, presents for user approval
7. User approves plan
8. LLM enters Implementation stage (direct execution, no subagent)
9. LLM executes work directly, domain guides loaded as needed
10. At phase end, non-actionable lessons route to appropriate stage guides

## Extensions

3a. Analysis reveals insufficient investigation:
    3a1. LLM returns to Investigation stage
    3a2. Continue at step 1

7a. User rejects plan:
    7a1. LLM returns to Planning stage with feedback
    7a2. Continue at step 5

10a. Guide already covers lesson:
    10a1. Skip adding duplicate lesson
    10a2. Continue

## Integration with Protocol Steps

| Protocol Step | IAPI Stage(s) | Lesson Routing Target |
|---------------|---------------|----------------------|
| Plan Mode Entry | Investigate, Analyze | investigation-guide.md, analysis-guide.md |
| Step 1a-1b | Analyze, Plan | analysis-guide.md, planning-guide.md |
| Step 1c-1e | Plan | planning-guide.md |
| Step 2 | Implement | Domain-specific guides |
| Step 3 | Analyze | Route non-actionable deductions to source stage |
| Step 4 | (cleanup) | Commit lesson updates to guides |

## Plan File Locality

Pervasive behaviors (task management, logging) must appear in plan file at each phase with full detail:

```markdown
## Phase N: [Name]
### Step 1 (IAP)
- Investigate: [exploration targets]
- Analyze: [what to grade]
- Plan: [approach to finalize]
- TaskCreate({"subject": "Phase N", "activeForm": "Working on Phase N"})

### Step 2 (Implement)
- [deliverables]

### Step 3-4 (Present/Cleanup)
- TaskUpdate({"taskId": "N", "status": "completed"})
```

This ensures task tracking happens - instructions only at Step 1d lack locality for compliance.

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| New phase started | Appropriate stage guide loads |
| Non-actionable deduction found | Routes to correct stage guide |
| Stage transition | Previous stage lessons captured |
| Investigation incomplete | Should not proceed to Analysis |

*Note: Behavioral test implementations in uc9-design.md*

## Trigger

LLM enters a new protocol phase requiring stage-specific guidance.

## Preconditions

- Stage-specific guides exist (or are created on first lesson)

## Success Guarantee

- Each stage has accumulated lessons loaded
- Non-actionable lessons route to appropriate stage
- Incremental improvement over time

## Minimal Guarantee

- Stages are recognized as distinct
- Lessons captured somewhere (even if not perfectly routed)

## Project Info

- Priority: P3 (Enhancement - builds on UC6 lesson capture)
- Frequency: Every protocol execution
