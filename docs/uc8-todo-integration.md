# Use Case: UC8 Todo Integration with Plan File

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** Tasks API, plan file

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Task definitions in plan file | Todo UI/display |
| Step expansion/collapse per phase | Tasks API implementation |
| Plan file as todo source of truth | Multi-agent coordination |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Claude, beginning a new phased effort, sketches the plan file with collapsed phase placeholders. When UC3-A starts, Claude expands the tasks for UC3's steps directly in the plan file: `[in_progress] UC3-A`, `[pending] UC3-B`, `[pending] UC3-C`. The Tasks API syncs from this structure. When UC3-A completes, Claude marks it `[completed]` in the plan and collapses detail. The plan file IS the task state—no separate tracking needed. The user likes this because plan and tasks are one artifact. Claude likes it because the plan file shows exactly what's active and what's done.

## Stakeholders & Interests

- **User:** Single artifact for plan + todos, visible progress
- **LLM:** Plan file is authoritative, no state drift
- **Protocol:** Todos telescope naturally with phase progression

## Preconditions

- Plan file exists with phase structure
- Tasks API available (or equivalent)

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
3. LLM expands phase to protocol steps in plan file, keeping future phases visible:
   ```
   [in_progress] Step 2: UC1-A use case doc
   [pending] Step 2: UC1-B design doc
   [pending] Step 2: UC1-C implementation
   [pending] Step 3: Present and await approval
   [pending] Step 4: Post-approval actions
   [pending] Phase 2: Plan/contract distinction  ← future phase
   [pending] Phase 3: Plan mode entry            ← future phase
   ```
4. LLM completes UC1-A, marks `[completed]` in plan
5. LLM marks UC1-B `[in_progress]`, continues
6. When UC1 complete, collapses to: `[completed] UC1: Step 1b sequencing`
7. LLM expands UC2 placeholder, repeat

## Extensions

2a. Tasks API not available:
    2a1. LLM maintains state in plan file only
    2a2. User sees progress via plan file structure
    2a3. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase started | Plan shows expanded steps for that phase |
| Step completed | Task marked `[completed]` |
| Phase completed | Collapse step tasks, keep phase visible |
| Multiple phases | Current phase steps expanded, future phases as single tasks |

## Todo Structure (Tasks API)

```
[completed] Step 1: Plan Validation
[in_progress] Step 2: UC3-A use case doc
[pending] Step 2: UC3-B design doc
[pending] Step 2: UC3-C implementation
[pending] Step 3: Present and await approval
[pending] Step 4: Post-approval actions
[pending] Phase 2: UC4-UC5 compliance fixes    ← future phase
[pending] Phase 3: UC6-UC7 new features        ← future phase
```

**Pattern:** Step deliverables prefixed with step number, future phases prefixed with "Phase".

## Protocol Step Mapping

Each sub-phase maps to protocol steps:

| Sub-phase | Protocol Steps |
|-----------|----------------|
| UC*-A (Use Case) | Step 1 (plan + present) |
| UC*-B (Design) | Step 1 (plan + present) |
| UC*-C (Implementation) | Steps 1-4 (full cycle with TDD) |

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Step 1 (start) | Expand current phase in plan file |
| Step 2 (start) | Telescope: collapse Step 1, expand Step 2 deliverables |
| Step 4c | Collapse completed phase, expand next |

## Project Info

- Priority: P2 (Compliance fix for observed failures)
- Frequency: Every phase transition
- Behavioral Goal Impact: Strengthens existing goal (progress tracking)
