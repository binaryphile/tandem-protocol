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
| **Skeleton** | Future phases: description + expansion instruction |
| **Expanded** | Current phase: tasks shown with `[ ]` |
| **Collapsed** | Completed phases: tasks removed, parent marked `[x]` |

**Collapse = remove tasks, keep parent with checkmark.** History visible.

```
[x] Phase 1: Auth middleware           ← collapsed (tasks removed)
[x] Phase 2: Event logging             ← collapsed (tasks removed)
[ ] Phase 3: README update             ← current (expanded below)
    [ ] Task A
    [ ] Task B
    ...
[ ] Phase 4: Future work               ← skeleton (expand when reached)
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
- Completed phases collapsed (tasks removed, parent `[x]`)
- Active phase expanded with `[ ]` checkboxes
- Future phases as skeletons

## Minimal Guarantee

- Plan file tracks phase/step completion with checkboxes

## Trigger

LLM enters a new phase or completes a step within current phase.

## Main Success Scenario

1. LLM creates plan with phase skeletons
2. LLM enters first phase, expands Plan/Implement stages:
   **Plan file:**
   ```
   [ ] Phase 1: Auth middleware
       [ ] Plan
       [ ] Implement
   [ ] Phase 2: Event logging          ← skeleton
   [ ] Phase 3: README update          ← skeleton
   ```
3. LLM completes Plan stage, reaches Gate 1, user approves
4. LLM marks Plan `[x]`, expands Implement with deliverable tasks, syncs to Tasks API:
   **Plan file:**
   ```
   [ ] Phase 1: Auth middleware
       [x] Plan                        ← completed
       [ ] Implement                   ← current (expanded)
           [ ] Add middleware
           [ ] Add tests
           [ ] Update docs
   [ ] Phase 2: Event logging          ← skeleton
   ```
   **Tasks API:** TaskCreate for each deliverable, first `in_progress`
5. LLM completes deliverables, marks `[x]` in plan, updates Tasks API to `completed`
6. LLM reaches Gate 2, user approves
7. LLM collapses phase (removes stages, marks parent `[x]`), deletes Tasks API entries:
   **Plan file:**
   ```
   [x] Phase 1: Auth middleware        ← collapsed
   [ ] Phase 2: Event logging          ← now entering
       [ ] Plan
       [ ] Implement
   [ ] Phase 3: README update          ← skeleton
   ```
8. Repeat until all phases complete

## Extensions

2a. Tasks API not available:
    2a1. LLM maintains state in plan file only (checkboxes)
    2a2. User sees progress via plan file structure
    2a3. Continue at step 3

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Phase entered | Plan file: Plan/Implement stages added with `[ ]` |
| Gate 1 approved | Plan `[x]`, Implement expanded with tasks, Tasks API synced |
| Task completed | Plan file: task `[x]`, Tasks API: `completed` |
| Gate 2 approved | Plan file: collapse phase, Tasks API: all tasks `deleted` |
| Multiple phases | Current expanded, completed collapsed, future as skeletons |

## Three-Level Hierarchy

Telescoping operates at three levels:

| Level | What | Expanded When |
|-------|------|---------------|
| **Phase** | From plan file (UC6, UC7, etc.) | Always visible |
| **Stage** | Protocol stages (Plan, Implement) | Current phase |
| **Task** | Deliverables for current stage | Current stage |

**Plan file** (document):
```
[x] Phase 1: Auth middleware        ← collapsed (stages removed)
[ ] Phase 2: Event logging          ← current phase
    [x] Plan                        ← completed stage (tasks removed)
    [ ] Implement                   ← current stage (expanded)
        [ ] Add logging middleware
        [ ] Update tests
        [ ] Update docs
[ ] Phase 3: README update          ← skeleton (stages not yet created)
```

**Tasks API** (tool) - mirrors current stage only:
```
[in_progress] Add logging middleware
[pending] Update tests
[pending] Update docs
```

**Telescoping rules:**
- **Enter phase:** Create Plan and Implement stage entries in plan file
- **Gate 1 (Plan → Implement):** Mark Plan `[x]`, expand Implement with deliverable tasks, sync to Tasks API
- **Gate 2 (phase complete):** Mark Implement `[x]`, collapse phase (remove stages), delete all Tasks API entries

## Protocol Stage Mapping

Each phase follows the PI model:

| Stage | What Happens | Gate |
|-------|--------------|------|
| Plan | Explore, design, present approach | Gate 1: approve plan |
| Implement | Execute deliverables, present results | Gate 2: approve results |

For complex phases (like UC implementations), the Tasks API tracks deliverables within Implement stage.

## Integration Points in Protocol

| Event | Plan File Action | Tasks API Action |
|-------|-----------------|------------------|
| Enter phase | Add Plan/Implement stages with `[ ]` | (none yet) |
| Gate 1 approval | Mark Plan `[x]`, expand Implement tasks | TaskCreate for each deliverable, first `in_progress` |
| Task completion | Mark task `[x]` | TaskUpdate to `completed`, next to `in_progress` |
| Gate 2 approval | Mark Implement `[x]`, collapse phase | TaskUpdate `deleted` for all phase tasks |

## Locality: TaskAPI Calls in Plan File

**Critical:** Plan files must include explicit TaskAPI instructions at trigger points. Claude executes what it sees at the moment of action.

**Plan file template with locality:**
```markdown
## At Gate 1 Approval
- Mark Plan stage `[x]}` in this file
- Expand Implement stage with deliverable tasks
- TaskCreate for each task in Tasks JSON below
- TaskUpdate first task to `in_progress`
- Log Contract entry to plan-log.md

## At Gate 2 Approval
- Mark Implement stage `[x]` in this file
- Collapse phase (remove stages, mark phase `[x]`)
- TaskUpdate `deleted` for each task (telescope clean)
- Log Completion entry to plan-log.md
- Commit deliverable + plan-log.md

## Tasks
[JSON array copied verbatim to TaskCreate calls after Gate 1]
```

**Why locality matters:** Without explicit instructions at the trigger point, Claude may forget to sync Tasks API even if the protocol mentions it elsewhere.

## Project Info

- Priority: P2 (Compliance fix for observed failures)
- Frequency: Every phase transition
- Behavioral Goal Impact: Strengthens existing goal (progress tracking)
