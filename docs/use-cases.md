# Tandem Protocol Use Cases

---

## UC2: Plan Mode & Content Distinction

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actor:** LLM (executing protocol)
**Priority:** P1 (High) — high frequency compliance failure | **Frequency:** Every protocol execution

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Plan file vs contract distinction | Other tool integrations |
| Plan mode timing | Plan mode UI/UX details |
| Content routing (HOW vs WHAT) | Log format specifications (see UC7) |
| Main success path only | Exceptional cases |

### System-in-Use Story

Alex starts a feature request. Claude enters plan mode and writes methodology to the plan file: "Phase by use case, TDD for implementation." After Alex approves, Claude records the contract with scope and criteria. Alex likes this separation because the plan file persists across sessions for reference, while the contract captures the immediate scope agreement. Alex can review "what we agreed" (contract) separately from "how we'll do it" (plan file).

### Stakeholders & Interests

- **User:** Plan and contract serve different purposes; confusion breaks workflow
- **LLM:** Needs clear guidance on which content goes where
- **Protocol:** Maintains separation of concerns (HOW vs WHAT)

### Preconditions

- Protocol execution is starting

### Success Guarantee

- Plan file contains HOW (approach, methodology, research strategy)
- Contract event contains WHAT (scope, deliverables, success criteria)
- Plan mode entered before planning begins
- Plan mode exited after approval, before contract publishing

### Minimal Guarantee

- No contract-style content in plan file
- No plan-style content in contract

### Trigger

User starts the protocol for a new task.

### Main Success Scenario

1. User requests a task requiring planning
2. System enters plan mode
3. System writes approach and methodology to plan file
4. System executes plan substeps (investigate, clarify, design)
5. User approves the plan
6. System exits plan mode
7. System records contract with scope and criteria
8. System proceeds to implementation

### Extensions

- 2a. Plan mode tools not available → present plan in conversation instead, continue at step 4
- 3a. System writes contract-style content to plan → VIOLATION; at step 7, extract scope from plan, publish as contract
- 6a. Plan mode tools not available → note not applicable, continue at step 7
- 7a. System writes plan-style content to contract → VIOLATION
- 8a. Multi-phase: plan file retained across phases, each phase gets own contract

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Plan file contains scope/deliverables | FAIL: Contract content in plan |
| Contract event contains methodology | FAIL: Plan content in contract |
| Plan mode exited before user approval | FAIL: Premature exit |
| Contract published while plan mode active | FAIL: Should exit first |

---

## UC3: Plan Mode Entry Sequence

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actor:** LLM (executing protocol)
**Priority:** P2 (Medium) — prevents "confident but wrong" summaries | **Frequency:** Every session start, every phase transition

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Standard entry sequence for ALL planning | Plan file format/structure |
| Phased and non-phased sessions | Plan creation details |
| Quoting existing plan verbatim | Grade/improve cycle mechanics (see UC9) |
| Auto-grading analysis then plan | Manual grading on explicit request |
| Waiting for user direction | Mid-phase re-entry |
| Main success path only | Exceptional cases |

### System-in-Use Story

Alex resumes work on a phased project. Before doing anything, Claude reads the existing plan and quotes it verbatim — no summarizing, no interpreting. Then Claude asks itself: "Do I actually understand this?" and gives an honest grade. Only after that does Claude evaluate "Is this plan sound?" Alex sees both grades and the quoted plan. If Claude misunderstood something, the low analysis grade reveals it immediately — before any work begins. Alex says "improve analysis" and Claude re-reads, asks questions, tries again.

### Stakeholders & Interests

- **User:** Wants to verify Claude understood the plan correctly before work begins
- **LLM:** Needs clear checkpoint to surface misunderstandings early
- **Protocol:** Ensures plan continuity across sessions

### Preconditions

- Protocol is entering the Plan stage

### Success Guarantee

- Existing plan quoted verbatim (not summarized, not interpreted)
- Analysis grade provided FIRST
- Plan quality grade provided SECOND
- User explicitly directs next action — BLOCKING

### Minimal Guarantee

- User sees actual plan contents (not system's interpretation)
- System does not proceed without user direction

### Trigger

User starts the protocol for a task (new or continuing).

### Main Success Scenario

1. User initiates planning
2. System enters plan mode
3. System checks for existing plan
4. System finds existing plan
5. System quotes plan verbatim (no summarizing, no interpreting)
6. System grades own analysis: "Do I understand this?"
7. System grades plan quality: "Is this sound?"
8. System presents understanding and asks for direction
9. User directs: "improve" or "proceed"

### Extensions

- 3a. No existing plan → note "No existing plan found", create new plan, skip to step 8
- 4a. Plan too large to quote fully → quote relevant sections, note which were excerpted
- 6a. Analysis grade is low → explicitly list points of confusion; user may clarify
- 7a. Plan grade is low → explicitly list weaknesses; user may choose to improve
- 9a. User says "improve" → address deductions, re-grade both, return to step 8
- 9b. User says "proceed" → exit plan mode, record contract, proceed to implementation

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Existing plan found | Must quote verbatim, not summarize |
| After quoting plan | Must provide analysis grade FIRST |
| After analysis grade | Must provide plan quality grade SECOND |
| Order violation | FAIL if plan grade appears before analysis grade |
| After both grades | Must wait for user direction (BLOCKING) |
| User hasn't directed | Must NOT proceed to implementation |
| Summarized instead of quoted | FAIL — defeats purpose of surfacing misunderstandings |

---

## UC5: Line Reference Guidance

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actor:** LLM (executing protocol)
**Priority:** P3 (Low frequency failure) | **Frequency:** When edits affect referenced lines

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Verify line numbers after edits | Specific tooling for verification |
| Guidance to re-check references | Automated line tracking |
| Main success path only | Exceptional cases |

### System-in-Use Story

Alex reviews Claude's implementation results and notices the plan references line 45 of auth.go — but Claude just added 20 lines above that section. Before presenting, Claude re-reads the affected sections to verify line references still point to the right places. Alex likes this because stale line numbers in documentation cause confusion.

### Stakeholders & Interests

- **User:** Wants accurate references when reviewing work
- **LLM:** Needs reminder that line numbers drift after edits
- **Protocol:** Maintains documentation accuracy

### Preconditions

- System has made edits to a file
- Plan or contract references specific line numbers

### Success Guarantee

- Line references verified after edits
- Stale references updated before presenting results

### Minimal Guarantee

- System aware that line numbers may have shifted

### Trigger

System completes edits to a file that has line references in plan or contract.

### Main Success Scenario

1. System completes edits to a file
2. System notes that plan or contract references line numbers in that file
3. System re-reads relevant sections to verify line numbers
4. System updates any stale references before presenting results

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| After edits with line refs | Must verify references still accurate |
| Stale line number found | Must update before presenting |

---

## UC6: Lesson Capture from Grading

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actors:** LLM (executing protocol), guide files
**Priority:** P4 (New feature) | **Frequency:** Every grading cycle

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Capturing non-actionable lessons during grading | Guide file format/structure |
| Routing lessons to appropriate guide | Automated lesson extraction |
| Distinguishing deductions from lessons | |
| Main success path only | Exceptional cases |

### System-in-Use Story

Alex reviews Claude's grade on a feature implementation. Claude identified a gap: "The error messages could be more user-friendly." This isn't fixable now — the feature works, the contract is complete. Instead of inflating the grade deduction or ignoring it, Claude notes the lesson in the appropriate guide for future reference. Alex likes this because insights aren't lost, the grade stays focused on actionable items, and patterns get captured for future work.

### Stakeholders & Interests

- **User:** Wants insights preserved without grade inflation
- **LLM:** Needs clear rule for what's a deduction vs. a lesson
- **Protocol:** Maintains grading accuracy while enabling improvement

### Preconditions

- System is performing grading at a gate
- Gap identified that isn't actionable in current session

### Success Guarantee

- Actionable gaps become grade deductions
- Non-actionable gaps become lessons in guides
- No grade inflation from non-actionable items
- Lessons preserved for future reference

### Minimal Guarantee

- Clear distinction attempted between deduction and lesson
- No lessons silently dropped

### Trigger

System identifies a gap during grading that cannot be fixed in the current session.

### Actionability Test

**"Can I fix this now?"** means ALL of:
- Within current contract scope
- Fixable in this session
- Not requiring user decisions not yet made
- Not a process/methodology improvement (those go to guides)

### Main Success Scenario

1. System performs grading on completed work
2. System identifies gap in deliverable
3. System applies actionability test: "Can I fix this now?"
4. Gap is NOT actionable (out of scope, future work, process improvement)
5. System captures lesson in appropriate guide
6. System continues grading without deducting for this gap

### Extensions

- 3a. Gap IS actionable → include as grade deduction; if user says "improve", fix it
- 5a. No appropriate guide exists → note lesson in grading output, suggest guide creation
- 5b. Lesson duplicates existing guide content → note "already captured", continue

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Non-actionable gap found | Must route to guide, not grade |
| Actionable gap found | Must include in grade deductions |
| Grade contains non-actionable items | FAIL: Grade inflation |
| Lesson identified but not captured | FAIL: Insight lost |

---

## UC7: Event Logging

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actors:** LLM (executing protocol), event store
**Priority:** P4 (New feature) | **Frequency:** Every protocol execution

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Contract events (scope/deliverables) | Automated log analysis |
| Completion events (deliverable done) | Log aggregation tools |
| Interaction events (/i /c /g cycles) | |
| Events recorded in event store | |

### System-in-Use Story

Alex starts a new phase and sees Claude publish the scope with criteria: "Phase 1 - auth middleware | middleware | tests | docs". As work completes, Claude publishes completion with evidence for each criterion. Alex invokes `/i` to improve. Claude self-assesses, finds a missing edge case, fixes it, and logs the interaction. Alex likes this because criteria verification is explicit — can't claim "3/3 met" without evidence.

### Stakeholders & Interests

- **User:** Wants record of session flow without managing files
- **LLM:** Needs to capture behavioral data for improvement
- **Protocol:** Enables future behavioral analysis via event logging

### Preconditions

- Protocol execution is in progress

### Success Guarantee

- All protocol events recorded
- Event types distinguish scope (contract), progress (completion), and feedback (interaction)

### Minimal Guarantee

- Major events captured

### Trigger

System reaches a protocol milestone: phase start (contract), deliverable done (completion), or user input (interaction).

### Main Success Scenario

1. System reaches a protocol milestone
2. System determines event type (contract, completion, or interaction)
3. System records event
4. System continues protocol execution

### Extensions

- 3a. Event store unavailable → report error to user, continue without logging

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Phase started (Implementation Gate) | Must have contract event with scope |
| Deliverable complete (Completion Gate) | Must have completion event with evidence |
| User feedback given | Must have interaction event with response |
| `/i` cycle occurred | Must show interaction with description of fix |

---

## UC9: Grading Cycles & Task Events

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actors:** LLM (executing protocol), event store
**Priority:** P2 (Medium) | **Frequency:** Every gate interaction

### In/Out List

| In Scope | Out of Scope |
|---|---|
| `/i` improve cycles at both gates | Automated grading triggers |
| Auto `/i` cycles before presentation | Grading rubrics or scoring |
| `/c` compliance grading | Per-criterion task tracking |
| `/g` external review grading | |
| Task events at gates | |
| Grading loops in state machine diagrams | |

### System-in-Use Story

Claude finishes implementing and presents results at the Completion Gate. User types `/i`. Claude self-assesses, finds a missing validation check, fixes it, and logs the interaction. Claude re-presents. User types `/i` again. Claude finds nothing more. User types `/c`. Claude grades against the project's Go guide, finds a naming violation, fixes it, and logs. Re-presents. User types `proceed`. Claude executes the Completion Gate actions, closing the task and committing.

### Stakeholders & Interests

- **User:** Wants iterative quality improvement without complex commands
- **LLM:** Needs clear loop structure to know when to self-assess vs wait
- **Orchestrator:** Needs machine-readable task events to detect gate crossings

### Preconditions

- Protocol is at a gate (step 1d or 3b has presented)

### Success Guarantee

- All grading interactions recorded
- Gate task events published

### Minimal Guarantee

- Grading interaction logged even if fix attempt fails

### Trigger

User types `/i`, `/c`, or `/g` at either gate. Recommended sequence: `/g` (once at entry, calibrated projects only), then `/i` (repeated), then `/c` (after plateau).

### Main Success Scenario

1. User types `/i` at a gate
2. System records the interaction
3. System self-assesses work, identifies issues
4. System fixes issues
5. System re-presents at the current gate's presentation step (1d or 3b)
6. User repeats or advances the gate

### Extensions

- 1a. User types `/c` → grade against project guides, continue at step 2
- 1b. User types `/g` → apply external review feedback, continue at step 2
- 1c. `/g` already used at this gate → inform user, suggest `/i`
- 2a. Auto `/i` ran before initial presentation (up to 3) → user sees polished result
- 3a. No issues found → report, re-present unchanged
- 6a. User advances gate → execute gate actions
- 6b. Gate event recording fails → report error, do not commit

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| `/i` at either gate | Interaction logged, issues found and fixed, re-present |
| `/c` at either gate | Compliance grade against guides, fix violations |
| `/g` at either gate | External feedback applied |
| `/g` repeated at same gate | Once per gate — suggest `/i` instead |
| Gate advanced after grading | Gate actions executed |

---

## UC10: Task Claiming

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actors:** LLM (executing protocol), orchestrator, event store
**Priority:** P3 (Multi-agent coordination) | **Frequency:** Every protocol execution

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Task creation and claiming at gates | Task prioritization |
| Claim lifecycle (claim, release) | Multi-agent scheduling |
| Task completion releasing claims | Claim conflict resolution |
| Task stream inspection | |

### System-in-Use Story

Alex starts a multi-phase project. At the Implementation Gate, Claude creates a task and claims it — signaling to any orchestrator that this work is in progress. Alex works through the implementation. At the Completion Gate, Claude marks the task done, which implicitly releases the claim. Later, Alex checks for orphaned tasks and sees none. In a multi-agent scenario, another agent checking active claims would have seen Claude's claim and avoided duplicate work.

### Stakeholders & Interests

- **User:** Wants tasks tracked without manual bookkeeping
- **LLM:** Needs clear task lifecycle tied to protocol gates
- **Orchestrator:** Needs to detect which tasks are in progress and by whom

### Preconditions

- Protocol is at a gate

### Success Guarantee

- Tasks created at Implementation Gate are immediately claimed
- Completed tasks have claims released
- Task stream shows accurate open/claimed/done state

### Minimal Guarantee

- Task created even if claim fails

### Trigger

System reaches the Implementation Gate (task creation) or Completion Gate (task completion).

### Main Success Scenario

1. User approves plan at Implementation Gate
2. System creates task in event store
3. System claims the task
4. User works through implementation
5. User approves at Completion Gate
6. System marks task done (claim released implicitly)

### Extensions

- 3a. Task already claimed by another agent → warn, claim anyway (overwrites)
- 3b. Claim fails (event store unavailable) → report error, proceed without claim
- 6a. User wants to release claim without completing → user runs unclaim command

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Implementation Gate reached | Task created and claimed |
| Completion Gate reached | Task marked done, claim released |
| Task already claimed | Warning shown, claim overwritten |
| Open tasks queried | Accurate list of uncompleted tasks |
| Active claims queried | Only claims on open tasks shown |

---

## UC11: Skeptical Review

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actor:** LLM (executing protocol)
**Priority:** P3 (Quality assurance) | **Frequency:** On user request at any stage

### In/Out List

| In Scope | Out of Scope |
|---|---|
| User-triggered skeptical review of current work | Automated skepticism triggers |
| Challenge assumptions in plan or implementation | Grading rubrics or scoring |
| Surface hidden risks and blind spots | External review mechanics (see `/g` in UC9) |
| Main success path only | Exceptional cases |

### System-in-Use Story

Alex is reviewing Claude's plan for a database migration. The plan looks reasonable, but Alex has a gut feeling something is off. Alex types `/s`. Claude steps back and adversarially challenges its own work: "I assumed the migration can run online, but I didn't verify whether the table lock duration is acceptable for the production traffic volume." Alex says "good catch" and they adjust the plan before implementation begins.

### Stakeholders & Interests

- **User:** Wants an honest second look that challenges rather than confirms
- **LLM:** Needs explicit permission to be adversarial about its own work
- **Protocol:** Provides a mechanism for the user to invoke critical thinking on demand

### Preconditions

- Protocol is at any stage with work product to review (plan, implementation, or results)

### Success Guarantee

- Assumptions in current work explicitly identified and challenged
- Hidden risks or blind spots surfaced
- Review is adversarial, not confirmatory

### Minimal Guarantee

- System attempts genuine critique rather than restating what was already presented

### Trigger

User types `/s` at any point during protocol execution.

### Main Success Scenario

1. User types `/s`
2. System identifies current protocol stage and work product
3. System adversarially reviews its own work, challenging assumptions
4. System surfaces risks, blind spots, and unverified assumptions
5. System presents findings to user
6. User directs: address findings or continue

### Extensions

- 3a. No assumptions to challenge → system reports high confidence with reasoning
- 6a. User says "fix it" → system addresses findings, re-presents at current stage
- 6b. User says "noted" → system continues without changes

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| `/s` invoked | Must challenge, not confirm |
| Review finds issues | Must present clearly with reasoning |
| Review finds nothing | Must explain why confidence is high, not just say "looks good" |
| After findings presented | Must wait for user direction |
