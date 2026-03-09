# Use Case: UC8 Todo Integration with Plan File

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Plan file lifecycle (skeleton/expand/collapse) | Todo UI/display |
| Task tracking synchronization from plan file | Task tracking implementation |
| Phase expansion/collapse per phase | Multi-agent coordination |
| Main success path only | Exceptional cases |

## System-in-Use Story

> Alex, beginning a new phased effort, sees Claude sketch the plan file with phase outlines. When Phase 1 starts, Claude expands the current phase to show deliverables. As work progresses, Claude checks off items. When Phase 1 completes, Claude collapses it (removes detail, marks done) and expands Phase 2. Alex likes this because the plan file shows progress at a glance — completed phases are compact, the current phase shows what's being worked on, future phases are just names.

## Stakeholders & Interests

- **User:** Plan file shows progress at a glance
- **LLM:** Plan file is source of truth, task tracking syncs from it
- **Protocol:** Telescoping works consistently

## Preconditions

- Plan file exists with phase structure

## Success Guarantee

- Plan file evolves as phases progress: future phases are summaries, active phase shows detail, completed phases are compact
- User sees current work at a glance without navigating completed or future detail

## Minimal Guarantee

- Plan file tracks phase completion

## Trigger

User enters a new phase or completes a phase within a project.

## Main Success Scenario

1. User starts a multi-phase project
2. System creates plan with phase outlines (future phases as skeletons)
3. System enters first phase, expands it with deliverables
4. User approves plan at Implementation Gate
5. System completes deliverables, marks progress
6. User approves at Completion Gate
7. System collapses completed phase (removes detail, marks done)
8. System expands next phase, repeats

## Extensions

3a. Task tracking not available:
    3a1. System maintains state in plan file only
    3a2. User sees progress via plan file structure
    3a3. Continue at step 4

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase entered | Current phase expanded with deliverables |
| Implementation Gate approved | Contract published, task tracking updated |
| Deliverable completed | Progress marked in plan file |
| Completion Gate approved | Phase collapsed, next phase expanded |
| Multiple phases | Current expanded, completed collapsed, future as skeletons |

## Project Info

- Priority: P2 (Compliance fix for observed failures)
- Frequency: Every phase transition
