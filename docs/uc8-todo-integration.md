# Use Case: UC8 Todo Integration with Plan File

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** Tasks API, plan file

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Plan file lifecycle (skeleton/expand/collapse) | Todo UI/display |
| Tasks API synchronization from plan file | Tasks API implementation |
| Step expansion/collapse per phase | Multi-agent coordination |
| Main success path only | Exceptional cases |

## Two Artifacts, One Source of Truth

**Plan file** (`~/.claude/plans/*.md`) and **Tasks API** (`TaskCreate/Update/List`) are separate but synchronized:

| Artifact | Format | Purpose |
|----------|--------|---------|
| Plan file | `[x]`/`[ ]` checkboxes | Document - visible to user, groomed as phases complete |
| Tasks API | `completed/in_progress/pending` | Tool - progress tracking, ephemeral per session |

**Sync direction:** Plan file → Tasks API (plan file is source of truth)

## Plan File Lifecycle

| State | Plan File Content |
|-------|-------------------|
| **Skeleton** | Future phases: IAPI substeps listed, no detail |
| **Expanded** | Current phase: substeps shown with `[ ]` |
| **Collapsed** | Completed phases: substeps removed, parent marked `[x]` |

**Collapse = remove substeps, keep parent with checkmark.** History visible.

```
[x] Phase 1: Auth middleware           ← collapsed (substeps removed)
[x] Phase 2: Event logging             ← collapsed (substeps removed)
[ ] Phase 3: README update             ← current (expanded below)
    [ ] Step 1a: Present understanding
    [ ] Step 1b: Ask questions
    [ ] Step 1c: Request approval
    ...
[ ] Phase 4: Future work               ← skeleton (IAPI substeps, no detail)
```

## System-in-Use Story

> Claude, beginning a new phased effort, sketches the plan file with phase skeletons. When Phase 1 starts, Claude expands the current phase to show steps with `[ ]` checkboxes, syncs to Tasks API with `pending` status. As work progresses, Claude checks off items `[x]` in the plan file and updates Tasks API to `completed`. When Phase 1 completes, Claude collapses it (removes substeps, marks parent `[x]`) and expands Phase 2. The user likes this because the plan file shows progress at a glance. Claude likes it because Tasks API stays in sync without drift.

## Stakeholders & Interests

- **User:** Plan file shows progress at a glance, Tasks API provides spinners/status
- **LLM:** Plan file is source of truth, Tasks API syncs from it
- **Protocol:** Telescoping works in both artifacts consistently

## Preconditions

- Plan file exists with phase structure
- Tasks API available (or plan file serves as fallback)

## Success Guarantee

- Plan file lifecycle: skeleton → expand → collapse
- Tasks API syncs from plan file state
- Completed phases collapsed (substeps removed, parent `[x]`)
- Active phase expanded with `[ ]` checkboxes
- Future phases as skeletons

## Minimal Guarantee

- Plan file tracks phase/step completion with checkboxes

## Trigger

LLM enters a new phase or completes a step within current phase.

## Main Success Scenario

1. LLM creates plan with phase skeletons (IAPI substeps listed)
2. LLM enters first phase, expands it:
   **Plan file:**
   ```
   [ ] Phase 1: Auth middleware
       [ ] Step 1a: Present understanding
       [ ] Step 1b: Ask questions
       [ ] Step 1c: Request approval
       ...
   [ ] Phase 2: Event logging          ← skeleton
   [ ] Phase 3: README update          ← skeleton
   ```
   **Tasks API:** Creates tasks with `pending` status, marks Step 1a `in_progress`
3. LLM completes Step 1a, marks `[x]` in plan, updates Tasks API to `completed`
4. LLM continues through steps, checking off `[x]` and syncing Tasks API
5. When Phase 1 complete, collapse in plan file (remove substeps, mark parent `[x]`):
   ```
   [x] Phase 1: Auth middleware        ← collapsed
   [ ] Phase 2: Event logging          ← now expanding
       [ ] Step 1a: Present understanding
       ...
   [ ] Phase 3: README update          ← skeleton
   ```
6. LLM deletes old tasks, creates new ones for Phase 2
7. Repeat until all phases complete

## Extensions

2a. Tasks API not available:
    2a1. LLM maintains state in plan file only (checkboxes)
    2a2. User sees progress via plan file structure
    2a3. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase started | Plan file: substeps expanded with `[ ]` |
| Step completed | Plan file: `[x]`, Tasks API: `completed` |
| Phase completed | Plan file: collapse (remove substeps, `[x]` parent) |
| Multiple phases | Current expanded, completed collapsed, future as skeletons |

## Parallel Structure

**Plan file** (document):
```
[x] Phase 1: Auth middleware        ← collapsed
[ ] Phase 2: Event logging          ← current (expanded)
    [x] Step 1: Plan validation
    [ ] Step 2: Implementation
    [ ] Step 3: Present
    [ ] Step 4: Post-approval
[ ] Phase 3: README update          ← skeleton
```

**Tasks API** (tool):
```
[completed] Step 1: Plan validation
[in_progress] Step 2: Implementation
[pending] Step 3: Present and await approval
[pending] Step 4: Post-approval actions
[pending] Phase 3: README update
```

**Note:** Collapsed phases don't appear in Tasks API (history is in plan file).

## Protocol Step Mapping

Each sub-phase maps to protocol steps:

| Sub-phase | Protocol Steps |
|-----------|----------------|
| UC*-A (Use Case) | Step 1 (plan + present) |
| UC*-B (Design) | Step 1 (plan + present) |
| UC*-C (Implementation) | Steps 1-4 (full cycle with TDD) |

## Integration Points in Protocol

| Step | Plan File Action | Tasks API Action |
|------|-----------------|------------------|
| Step 1 (start) | Expand current phase (`[ ]` substeps) | Create tasks with `pending` |
| Step completion | Mark `[x]` | Update to `completed` |
| Step 4c | Collapse phase (remove substeps, `[x]` parent) | Delete completed, create next |

## Project Info

- Priority: P2 (Compliance fix for observed failures)
- Frequency: Every phase transition
- Behavioral Goal Impact: Strengthens existing goal (progress tracking)
