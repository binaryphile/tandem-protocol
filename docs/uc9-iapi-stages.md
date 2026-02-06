# Use Case: UC9 IAPI Stage Model

**Scope:** Tandem Protocol
**Level:** White (strategic - spans multiple user sessions)
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** Stage-specific skills/guides

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Four orthogonal stages: Investigate, Analyze, Plan, Implement | Stage skill implementation details |
| Stage-specific guide loading | Guide file format |
| Lesson routing to stage guides | Automated lesson extraction |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Claude, starting a new feature request, enters the Investigation stage. The investigation skill loads with accumulated lessons from past investigations ("check for existing patterns before proposing new ones", "verify dependencies early"). Claude explores the codebase, then transitions to Analysis. The analysis skill loads with its own lessons ("grade understanding before proceeding", "identify assumptions explicitly"). After analysis confirms understanding, Claude enters Planning with planning-specific lessons. Finally, Implementation begins with implementation lessons loaded. When grading reveals a non-actionable deduction like "should have checked for race conditions during investigation", that lesson routes to the investigation guide—improving future investigations without penalizing the current grade.

## Stakeholders & Interests

- **User:** Wants Claude to get better at each stage over time
- **LLM:** Needs stage-appropriate guidance loaded at the right time
- **Protocol:** Enables incremental improvement through lesson accumulation

## The Four Stages

| Stage | Focus | Key Question | Skill/Guide |
|-------|-------|--------------|-------------|
| **I**nvestigate | Explore context | "What exists?" | investigation-guide.md |
| **A**nalyze | Grade understanding | "Do I understand?" | analysis-guide.md |
| **P**lan | Design approach | "How should we do this?" | planning-guide.md |
| **I**mplement | Execute work | "Build it right" | (domain-specific guides) |

## Stage Characteristics

### Investigate
- Read-only exploration
- No commitments made
- Output: Context gathered, patterns identified

### Analyze
- Grade own understanding (/a skill)
- Identify gaps and assumptions
- Output: Confidence level, clarifying questions

### Plan
- Design approach (/p skill)
- Consider alternatives
- Output: Approved plan with success criteria

### Implement
- Execute the work
- Follow domain guides (Go Dev, FP, Khorikov, etc.)
- Output: Deliverable meeting success criteria

## Lesson Routing

When grading produces non-actionable deductions (per UC6), route to the stage where the lesson applies:

| Lesson Type | Target Stage | Example |
|-------------|--------------|---------|
| "Should have explored X first" | Investigate | "Check for existing error handling patterns" |
| "Misunderstood requirement Y" | Analyze | "Verify assumptions about API contracts" |
| "Approach Z would have been simpler" | Plan | "Consider simpler alternatives before complex ones" |
| "Code pattern W caused issues" | Implement | Routes to domain-specific guide |

## Integration with Protocol Steps

| Protocol Step | IAPI Stage(s) | Notes |
|---------------|---------------|-------|
| Plan Mode Entry | Investigate, Analyze | Explore then grade understanding |
| Step 1a-1b | Analyze, Plan | Present understanding, ask questions |
| Step 1c-1e | Plan | Finalize and commit to plan |
| Step 2 | Implement | Execute the work |
| Step 3-4 | Analyze | Grade results, identify lessons |
| Step 5 | (cleanup) | Archive, route lessons to guides |

## Skill Loading Pattern

```python
# At Investigation start
if skill_available("investigate"):
    load_skill("investigate")  # Loads investigation-guide.md lessons

# At Analysis start
if skill_available("analyze"):
    load_skill("analyze")  # Loads analysis-guide.md lessons

# At Planning start
if skill_available("plan"):
    load_skill("plan")  # Loads planning-guide.md lessons

# At Implementation start
load_domain_guides()  # Go Dev, FP, Khorikov, etc. based on task
```

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| New phase started | Appropriate stage skill loads |
| Non-actionable deduction found | Routes to correct stage guide |
| Stage transition | Previous stage lessons captured |
| Investigation incomplete | Should not proceed to Analysis |

## Preconditions

- Stage-specific guides exist (or are created on first lesson)
- Skills configured to load guides at stage entry

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
- Behavioral Goal Impact: +1 new goal (stage-specific improvement)
