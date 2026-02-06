# Use Case: UC8 Todo Integration with Plan File

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** TodoWrite tool, plan file

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| TodoWrite JSON in plan file | Todo UI/display |
| Step expansion/collapse per phase | TodoWrite tool implementation |
| Plan file as todo source of truth | Multi-agent coordination |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Claude, beginning a new phased effort, sketches the plan file with collapsed phase placeholders. When UC3-A starts, Claude expands the todo JSON for UC3's steps directly in the plan file: `[in_progress] UC3-A`, `[pending] UC3-B`, `[pending] UC3-C`. The TodoWrite tool reads from this structure. When UC3-A completes, Claude marks it `[completed]` in the plan and collapses detail. The plan file IS the todo state—no separate tracking needed. The user likes this because plan and todos are one artifact. Claude likes it because the plan file shows exactly what's active and what's done.

## Stakeholders & Interests

- **User:** Single artifact for plan + todos, visible progress
- **LLM:** Plan file is authoritative, no state drift
- **Protocol:** Todos telescope naturally with phase progression

## Preconditions

- Plan file exists with phase structure
- TodoWrite tool available (or equivalent)

## Success Guarantee

- Plan file contains todo JSON for current phase
- Completed phases collapsed to single line
- Active phase expanded to protocol steps
- Pending phases shown as placeholders

## Minimal Guarantee

- Some tracking of phase/step completion in plan

## Trigger

LLM enters a new phase or completes a step within current phase.

## Main Success Scenario

1. LLM creates plan with collapsed phase placeholders
2. LLM enters first phase (e.g., UC1-A)
3. LLM expands phase to protocol steps in plan file:
   ```
   [in_progress] UC1-A: Step 2 (create use case doc)
   [pending] UC1-B: Step 2 (create design doc)
   [pending] UC1-C: Steps 2-6 (TDD implementation)
   ```
4. LLM completes UC1-A, marks `[completed]` in plan
5. LLM marks UC1-B `[in_progress]`, continues
6. When UC1 complete, collapses to: `[completed] UC1: Step 1b sequencing`
7. LLM expands UC2 placeholder, repeat

## Extensions

2a. TodoWrite not available:
    2a1. LLM maintains state in plan file only
    2a2. User sees progress via plan file
    2a3. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase started | Plan shows expanded steps for that phase |
| Step completed | Plan marks step `[completed]` |
| Phase completed | Plan collapses phase to single line |
| Multiple phases | Only current phase expanded |

## Todo JSON Structure in Plan File

```markdown
## Phase List (Todo State)

### Completed (collapsed)
- [completed] UC1: Step 1b sequencing
- [completed] UC2: Plan/contract distinction

### Current (expanded)
- [completed] UC3-A: Use case doc
- [in_progress] UC3-B: Design doc
- [pending] UC3-C: Implementation (TDD)

### Pending (placeholders)
- [pending] UC4-UC5: Compliance fixes
- [pending] UC6-UC7: New features (may cut)
```

## Protocol Step Mapping

Each sub-phase maps to protocol steps:

| Sub-phase | Protocol Steps |
|-----------|----------------|
| UC*-A (Use Case) | Step 2 (plan + present) |
| UC*-B (Design) | Step 2 (plan + present) |
| UC*-C (Implementation) | Steps 2-6 (full cycle with TDD) |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 2 (start) | Expand current phase in plan file |
| Step 6d | Collapse completed phase, expand next |

## Project Info

- Priority: P2 (Compliance fix for observed failures)
- Frequency: Every phase transition
- Behavioral Goal Impact: Strengthens existing goal (progress tracking)
