# Use Case: UC10 Task Claiming

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** User (developer)
**Secondary Actors:** LLM (executing protocol), orchestrator, event store

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Task creation and claiming at gates | Task prioritization |
| Claim lifecycle (claim, release, timeout) | Multi-agent scheduling |
| Task completion releasing claims | Claim conflict resolution |
| Task stream inspection | |

## System-in-Use Story

> Alex starts a multi-phase project. At the Implementation Gate, Claude creates a task and claims it — signaling to any orchestrator that this work is in progress. Alex works through the implementation. At the Completion Gate, Claude marks the task done, which implicitly releases the claim. Later, Alex checks for orphaned tasks and sees none. In a multi-agent scenario, another agent checking active claims would have seen Claude's claim and avoided duplicate work.

## Stakeholders & Interests

- **User:** Wants tasks tracked without manual bookkeeping
- **LLM:** Needs clear task lifecycle tied to protocol gates
- **Orchestrator:** Needs to detect which tasks are in progress and by whom

## Preconditions

- Protocol is at a gate

## Success Guarantee

- Tasks created at Implementation Gate are immediately claimed
- Completed tasks have claims released
- Task stream shows accurate open/claimed/done state

## Minimal Guarantee

- Task created even if claim fails

## Trigger

System reaches the Implementation Gate (task creation) or Completion Gate (task completion).

## Main Success Scenario

1. User approves plan at Implementation Gate
2. System creates task in event store
3. System claims the task
4. User works through implementation
5. User approves at Completion Gate
6. System marks task done (claim released implicitly)

## Extensions

3a. Task already claimed by another agent:
    3a1. System warns that task is already claimed
    3a2. System claims the task anyway (overwrites previous claim)

3b. Claim fails (event store unavailable):
    3b1. System reports error
    3b2. Implementation proceeds without claim

6a. User wants to release claim without completing:
    6a1. User runs unclaim command
    6a2. Task remains open but unclaimed

## Guard Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Implementation Gate reached | Task created and claimed |
| Completion Gate reached | Task marked done, claim released |
| Task already claimed | Warning shown, claim overwritten |
| Open tasks queried | Accurate list of uncompleted tasks |
| Active claims queried | Only claims on open tasks shown |

## Project Info

- Priority: P3 (Multi-agent coordination)
- Frequency: Every protocol execution
