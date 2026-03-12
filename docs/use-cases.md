# Tandem Protocol Use Cases

All use cases: Scope = Tandem Protocol, Level = Blue, Primary Actor = User (developer), Secondary Actor = LLM (executing protocol).

---

## UC2: Plan Mode & Content Distinction

**Story:** Alex starts a feature request. Claude enters plan mode and writes methodology to the plan file. After Alex approves, Claude records the contract with scope and criteria. The plan file persists for reference; the contract captures the immediate scope agreement.

**Success Guarantee:**
- Plan file contains HOW (approach, methodology, research strategy)
- Contract event contains WHAT (scope, deliverables, success criteria)
- Plan mode entered before planning, exited after approval, before contract publishing

**Minimal Guarantee:** No contract-style content in plan, no plan-style content in contract.

**Main Success Scenario:**
1. User requests a task requiring planning
2. System enters plan mode
3. System writes approach and methodology to plan file
4. System executes plan substeps (investigate, clarify, design)
5. User approves the plan
6. System exits plan mode
7. System records contract with scope and criteria
8. System proceeds to implementation

**Extensions:**
- 3a. System writes contract-style content to plan → VIOLATION
- 7a. System writes plan-style content to contract → VIOLATION
- 8a. Multi-phase: plan file retained across phases, each phase gets own contract

**Guard Conditions:**
- Plan file contains scope/deliverables → FAIL
- Contract contains methodology → FAIL
- Plan mode exited before user approval → FAIL
- Contract published while plan mode active → FAIL

---

## UC3: Plan Mode Entry Sequence

**Story:** Alex resumes a phased project. Claude reads the existing plan and quotes it verbatim — no summarizing. Then asks: "Do I understand this?" and grades analysis. Only after does Claude evaluate "Is this plan sound?" If Claude misunderstood, the low analysis grade reveals it before any work begins.

**Success Guarantee:**
- Existing plan quoted verbatim (not summarized, not interpreted)
- Analysis grade provided FIRST
- Plan quality grade provided SECOND
- User explicitly directs next action — BLOCKING

**Minimal Guarantee:** User sees actual plan contents; system does not proceed without direction.

**Main Success Scenario:**
1. User initiates planning
2. System enters plan mode
3. System checks for existing plan
4. System finds existing plan
5. System quotes plan verbatim
6. System grades own analysis: "Do I understand this?"
7. System grades plan quality: "Is this sound?"
8. System presents and asks for direction
9. User directs: "improve" or "proceed"

**Extensions:**
- 3a. No existing plan → create new plan, skip to step 8
- 9a. User says "improve" → address deductions, re-grade, return to step 8
- 9b. User says "proceed" → exit plan mode, record contract, implement

**Guard Conditions:**
- Existing plan found → must quote verbatim, not summarize
- After quoting → analysis grade FIRST, plan grade SECOND
- After both grades → must wait for user direction (BLOCKING)
- Summarized instead of quoted → FAIL

---

## UC5: Line Reference Guidance

**Story:** Alex reviews Claude's implementation. The plan references line 45 of auth.go, but Claude added 20 lines above that section. Before presenting, Claude re-reads affected sections to verify references still point to the right places.

**Success Guarantee:** Line references verified after edits; stale references updated before presenting.

**Minimal Guarantee:** System aware that line numbers may have shifted.

**Main Success Scenario:**
1. System completes edits to a file
2. System notes that plan or contract references line numbers in that file
3. System re-reads relevant sections to verify line numbers
4. System updates stale references before presenting results

**Guard Conditions:**
- After edits with line refs → must verify still accurate
- Stale line number found → must update before presenting

---

## UC6: Lesson Capture from Grading

**Story:** Claude grades a feature implementation and identifies a gap: "error messages could be more user-friendly." This isn't fixable now. Instead of inflating the grade, Claude captures the lesson in the appropriate guide. Insights aren't lost, the grade stays focused on actionable items.

**Success Guarantee:**
- Actionable gaps → grade deductions
- Non-actionable gaps → lessons in guides
- No grade inflation from non-actionable items
- Lessons preserved for future reference

**Minimal Guarantee:** Clear distinction attempted; no lessons silently dropped.

**Actionability Test — "Can I fix this now?" means ALL of:**
- Within current contract scope
- Fixable in this session
- Not requiring user decisions not yet made
- Not a process/methodology improvement (those go to guides)

**Main Success Scenario:**
1. System performs grading on completed work
2. System identifies gap in deliverable
3. System applies actionability test: "Can I fix this now?"
4. Gap is NOT actionable
5. System captures lesson in appropriate guide
6. System continues grading without deducting for this gap

**Extensions:**
- 3a. Gap IS actionable → include as grade deduction; if user says "improve", fix it

**Guard Conditions:**
- Non-actionable gap → must route to guide, not grade
- Actionable gap → must include in deductions
- Grade contains non-actionable items → FAIL (grade inflation)
- Lesson identified but not captured → FAIL (insight lost)

---

## UC7: Event Logging

**Story:** Alex starts a new phase. Claude publishes scope with criteria. As work completes, Claude publishes completion with evidence per criterion. Alex invokes `/i`. Claude finds a missing edge case, fixes it, logs the interaction. Criteria verification is explicit — can't claim "3/3 met" without evidence.

**Success Guarantee:** All protocol events recorded; event types distinguish scope (contract), progress (completion), and feedback (interaction).

**Minimal Guarantee:** Major events captured.

**Main Success Scenario:**
1. System reaches a protocol milestone
2. System determines event type (contract, completion, or interaction)
3. System records event
4. System continues protocol execution

**Extensions:**
- 3a. Event store unavailable → report error, continue without logging

**Guard Conditions:**
- Implementation Gate reached → must have contract event with scope
- Completion Gate reached → must have completion event with evidence
- `/i` cycle occurred → must have interaction event with fix description

---

## UC9: Grading Cycles & Task Events

**Story:** Claude presents at the Completion Gate. User types `/i`. Claude finds a missing validation check, fixes it, logs, re-presents. User types `/i` again — nothing found. User types `/c`. Claude finds a naming violation per the Go guide, fixes it, logs. User types `proceed`. Claude executes gate actions, closing the task.

**Success Guarantee:** All grading interactions recorded; gate task events published.

**Minimal Guarantee:** Grading interaction logged even if fix attempt fails.

**Recommended sequence:** `/g` (once at entry, calibrated projects only) → `/i` (repeated until exhausted) → `/c` (after plateau).

**Main Success Scenario:**
1. User types `/i` at a gate
2. System records the interaction
3. System self-assesses, identifies issues
4. System fixes issues
5. System re-presents at current gate's presentation step (1d or 3b)
6. User repeats or advances the gate

**Extensions:**
- 1a. User types `/c` → grade against project guides, continue at step 2
- 1b. User types `/g` → apply external review feedback, continue at step 2
- 1c. `/g` already used at this gate → inform user, suggest `/i`
- 2a. Auto `/i` ran before initial presentation (up to 3) → user sees polished result
- 3a. No issues found → report, re-present unchanged
- 6a. User advances gate → execute gate actions

**Guard Conditions:**
- `/i` at gate → interaction logged, issues fixed, re-present
- `/c` at gate → compliance grade, fix violations
- `/g` at gate → external feedback applied
- `/g` repeated → once per gate, suggest `/i`

---

## UC10: Task Claiming

**Story:** Alex starts a multi-phase project. At the Implementation Gate, Claude creates a task and claims it — signaling to any orchestrator that this work is in progress. At the Completion Gate, Claude marks the task done, releasing the claim. Another agent checking active claims would have seen Claude's claim and avoided duplicate work.

**Success Guarantee:**
- Tasks created at Implementation Gate are immediately claimed
- Completed tasks have claims released
- Task stream shows accurate open/claimed/done state

**Minimal Guarantee:** Task created even if claim fails.

**Main Success Scenario:**
1. User approves plan at Implementation Gate
2. System creates task in event store
3. System claims the task
4. User works through implementation
5. User approves at Completion Gate
6. System marks task done (claim released implicitly)

**Extensions:**
- 3a. Task already claimed → warn, overwrite claim
- 3b. Claim fails → report error, proceed without claim
- 6a. Release without completing → user runs unclaim

**Guard Conditions:**
- Implementation Gate reached → task created and claimed
- Completion Gate reached → task done, claim released
- Task already claimed → warning shown, overwritten
- Open tasks queried → accurate list
