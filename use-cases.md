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
- Plan file post-1d.5-final-exit is **immutable** as a design contract until explicit `/loopback` regression (see README §1d.5 Plan immutability)

### Minimal Guarantee

- No contract-style content in plan file
- No plan-style content in contract

### Trigger

User starts the protocol for a new task.

### Main Success Scenario

1. User requests a task requiring planning
2. System enters plan mode
3. System writes approach and methodology to plan file
4. System executes plan substeps (investigate, clarify — at least one question, design)
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
- 9a. Post-impl investigation reveals plan needs reshape → fire `/loopback <impl-phase>->1c: <reason>`; re-enter plan mode; revise plan; publish new `evtctl plan` event with `"supersedes": <prior-plan-event-id>`; if criterion topology changed, also publish new `evtctl contract` with `"supersedes": <prior-contract-event-id>` (per Tier 1 #4070 supersedes-chain pattern; see README §1d.5 Plan immutability)

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Plan file contains scope/deliverables | FAIL: Contract content in plan |
| Contract event contains methodology | FAIL: Plan content in contract |
| Plan mode exited before user approval | FAIL: Premature exit |
| Contract published while plan mode active | FAIL: Should exit first |
| Clarify step (1b) skipped without questions | FAIL: Must ask at least one question |
| Plan file edited post-1d.5-final-exit without explicit `/loopback` regression | FAIL: silent mutation (see README §1d.5 Plan immutability) |

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
| Interaction events (/i /c /grade cycles) | |
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
| Gate crossed | Must have session memory with deliverables, lessons, decision points and rationales |
| Attestation published before docs re-read | FAIL: docs-late closure violated; pre-attestation review required |

---

## UC9: Grading Cycles & Task Events

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (developer) | **Secondary Actors:** LLM (executing protocol), event store
**Priority:** P2 (Medium) | **Frequency:** Every gate interaction for standard / high-risk tiers (waived for trivial-tier cycles per §1a Tier classification)

### In/Out List

| In Scope | Out of Scope |
|---|---|
| `/i` improve cycles at both gates (auto for standard/high-risk; manual-only for trivial) | Automated grading triggers (agent-driven beyond /grade) |
| Auto `/i` cycles before presentation (waived for trivial) | Grading rubrics or scoring |
| `/c` compliance grading | Per-criterion task tracking |
| `/grade` adversarial review (required at §1d.5 for standard/high-risk; waived for trivial; manual at any gate) | |
| Task events at gates | |
| Grading loops in state machine diagrams | |
| Tier-gated scaffolding (per §1a Tier classification) | |

### System-in-Use Story

Claude finishes §1a investigation and classifies the cycle's tier (drop / trivial / standard / high-risk per §1a Tier classification). For trivial-tier cycles, Claude skips Auto `/i` and `/grade` (eligibility predicate is itself the adversarial-review substitute). For standard / high-risk cycles, Claude finishes planning at §1d, then Auto `/i` runs (per Gate Grading ROI rule). Then required `/grade` (§1d.5): Claude invokes `/grade`, the skill `wl-copy`s a self-contained grading request, user pastes it to a fresh model context and pastes back the structured response (Grade:/Findings:/Verdict:). Claude absorbs findings via `/i`, re-grades if absorption changed substantive content, exits the loop when verdict APPROVES or rounds plateau on novelty. Each round is logged as an `evtctl interaction`. High-risk cycles additionally log `/phase` events at each phase entry and `/decision` events at major decision points. Claude then ExitPlanMode + asks "May I proceed?". User says proceed; gate fires.

### Stakeholders & Interests

- **User:** Wants iterative quality improvement without complex commands
- **LLM:** Needs clear loop structure to know when to self-assess vs wait
- **Orchestrator:** Needs machine-readable task events to detect gate crossings

### Preconditions

- Protocol is at a gate (step 1d or 3b has presented)
- Cycle tier has been classified at §1a (drop / trivial / standard / high-risk per §1a Tier classification)

### Success Guarantee

- All grading interactions recorded
- Gate task events published

### Minimal Guarantee

- Grading interaction logged even if fix attempt fails

### Trigger

(a) Required for standard / high-risk cycles: agent invokes `/grade` at §1d.5 (adversarial review sub-step). Waived for trivial-tier cycles per Extension 2d. (b) Optional: user types `/i`, `/c`, or `/grade` at either gate. If there are guides for compliance, a single `/c` runs first before the presentation step (1d or 3b).

### Main Success Scenario

0. Cycle tier was classified at §1a (this MSS describes standard/high-risk; trivial-tier branches at step 1, skipping to step 7)
1. Agent runs Auto `/i` at §1d (per Gate Grading ROI rule)
2. Agent invokes `/grade` at §1d.5 (skill wl-copies a self-contained grading request)
3. User pastes request to a fresh model context (avoids frame-expansion) and pastes the structured response back
4. Agent absorbs findings via `/i` (re-grades if absorption changed substantive content)
5. Loop exits when grader's verdict begins APPROVES or successive rounds plateau on novelty
6. Each grade round logged as `evtctl interaction "/grade r<N>: <letter>, <findings count>, <verdict-summary>"`
7. Agent ExitPlanMode + asks "May I proceed?"; user advances gate

### Extensions

- 1a. User types `/c` at gate → grade against project guides, continue at step 2
- 1b. User types `/grade` at gate (in addition to §1d.5 mandatory invocation) → apply external review feedback, continue at step 4
- 2a. Grader response missing prescribed shape (no `Grade:` / `Findings:` / `Verdict:` headings) → agent requests reformatting before parsing
- 2b. Grader verdict cannot be classified as APPROVE / SEND BACK / GAP REMAINS → agent asks user to clarify before loop exit
- 2c. Hard cap reached (5 rounds without APPROVE and without novelty plateau) → log `/loopback 1d.5->1c: review unbounded` and return to 1c (cycle is wrong-sized or grader is uncalibrated; parallel to §1a Scope check pattern from era #4997)
- 2d. Cycle classified as **trivial tier** at §1a → §1d.5 mandatory `/grade` is exempted (eligibility predicate is itself the substitute for adversarial review; manual `/grade` still permitted)
- 4a. Auto `/i` ran before §1d.5 (≥2 passes; cap 3 unless each surfaces a new defect class) → grader sees pre-polished result
- 5a. No findings → grader returns APPROVE → loop exits immediately
- 7a. Gate event recording fails → report error, do not commit

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| `/i` at either gate | Interaction logged, issues found and fixed, re-present |
| `/c` at either gate | Compliance grade against guides, fix violations |
| `/grade` mandatory at §1d.5 | Skill invoked; fresh-context paste; structured response parsed; loop until APPROVE or plateau, hard-capped at 5 rounds |
| Cycle classified as trivial tier | `/grade` exempted at §1d.5; manual `/grade` still allowed |
| `/grade` at any gate (manual) | Compose grading request, apply external feedback |
| Grader response missing structured headings | Agent requests reformatting; does not infer verdict from prose |
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

## UC11: Docs-First AND Docs-Late Closure Discipline

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** User (with delegated execution to LLM) | **Secondary Actor:** LLM (executing protocol)
**Priority:** P1 (High) — drift prevention | **Frequency:** Every cycle affecting user-visible behavior or design

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Pre-impl review of all three docs | Internal refactors (no doc impact) |
| Pre-attestation re-read of all three docs | evolution.md / gap-analysis.md updates |
| Two-pass audit: scope-internal + scope-external (per #6191) | Mechanical line-count enforcement |
| Literal evidence form on `docs refreshed` | Migrating UC2-UC10 to fully-dressed |
| Amendment commits BEFORE `evtctl complete` | |

### System-in-Use Story

Alex starts a cycle that adds a STOP-marker requirement. Before impl, Claude updates use-cases.md and design.md to reflect the new requirement (docs-first). After impl lands, Claude runs the **two-pass flow** (per #6191): scope-internal pass deep-re-reads each modified doc to catch incomplete propagation through every subsection; scope-external pass scans adjacent normative docs for transitively-induced drift. The scope-internal pass finds a subtle wording divergence in design.md (the new requirement isn't reflected in design.md's table of related concepts); Claude amends and commits before attestation. The attestation's `docs refreshed` criterion carries evidence `docs drift detected: yes (<amend-SHA>)`. Without the two-pass flow, the attestation would have referenced docs known to diverge from reality.

### Stakeholders & Interests

- **User:** Wants protocol docs that match what the protocol actually does; wants auditable evidence of doc-cycle alignment
- **LLM:** Wants explicit gate-time procedure to follow; wants a literal evidence form to compose
- **Protocol:** Wants drift between docs and impl to surface within the cycle that introduced it, not later

### Preconditions

- Cycle is at the Completion Gate (post-impl, pre-attestation)
- README, use-cases.md, design.md all exist at repo root
- The `docs refreshed` criterion is present in the cycle's contract

### Success Guarantee

- Both scope-internal pass (deep re-read of modified docs) and scope-external pass (scan of adjacent normative docs) have been performed before attestation (per #6191)
- If drift was detected, amendment commits landed BEFORE `evtctl complete`
- Attestation's `docs refreshed` evidence is one of five literal forms (see design.md "Docs-refreshed evidence form"):
  - `docs drift detected: yes (<SHA>[, <SHA>...])`
  - `docs drift detected: no (reviewed: README, use-cases.md, design.md)`
  - `docs refreshed: not applicable (internal refactor)`
  - `docs refreshed: not applicable (docs-only cycle)`
  - `docs drift detected: deferred (task #<N>)`
- Attestation never references docs known to be stale

### Minimal Guarantee

- The reviewer cannot satisfy `docs refreshed` with vague text; must commit to one of the two literal forms
- An attestation with stale-known docs would fail this UC's Guard Conditions

### Trigger

LLM completes implementation-phase /i passes (≥2) and prepares the Completion Gate bash block.

### Main Success Scenario

1. LLM finishes impl + 3b /i passes
2. LLM commits + pushes implementation changes
3. LLM runs **SCOPE-INTERNAL pass** — deep re-read of each doc the cycle is modifying
   a. Re-read every subsection header (and the prose under each) in each modified doc
   b. For each concept the cycle amends, verify the concept appears (and is correctly framed) in every section where it logically belongs: UCs — In/Out, MSS, Extensions, Guard Conditions, Trigger, Preconditions, Stakeholders, Frequency; README — every sub-step referencing the concept; design.md — rationale subsections, tables, test plan. **Also verify cross-references between sections** (e.g., MSS step renumbering propagates into Extension references to step numbers; section anchors in cross-references resolve to renamed/restructured targets)
   c. Verify propagation completeness, not just drift-presence
   d. Log: `evtctl interaction "/i 3d scope-internal: <evidence-form-or-summary>"`
4. LLM runs **SCOPE-EXTERNAL pass** — scan adjacent normative docs NOT being modified
   a. Scan FEATURES.md, evolution.md, planning-guide.md, protocol-guide.md, project-specific design docs (design-events.md if present), CLAUDE.md imports the cycle touched
   b. Identify any references that the cycle's amendment makes transitively stale
   c. Log: `evtctl interaction "/i 3d scope-external: <evidence-form-or-summary>"`
5. LLM determines drift status across BOTH passes (yes / no per pass)
6. If drift: LLM amends affected docs, commits ("docs: post-impl drift fix"), pushes; sets evidence to `docs drift detected: yes (<SHA>)`
7. If no drift: LLM sets evidence to `docs drift detected: no (reviewed: <doc-list>)`
8. LLM publishes attestation (`evtctl complete`) with the literal evidence on the `docs refreshed` criterion
9. LLM publishes `done` and stores completion memory

### Extensions

- 6a. Drift found in MULTIPLE docs:
  1. LLM amends each affected doc
  2. Commits may be combined into one "docs: post-impl drift fix" commit or split per doc; evidence records the final SHA
  3. Resume MSS step 8
- 7a. Drift amendment itself reveals further drift (recursive review):
  1. LLM amends iteratively, capping at 2 amendment cycles
  2. If still surfacing drift after 2 cycles, halt and ask user (cycle may need scope reconsideration, not just doc fix)
- 8a. Cycle is pure-internal-refactor (no user-visible behavior or design impact):
  1. Docs-first AND docs-late are skipped
  2. Evidence becomes `docs refreshed: not applicable (internal refactor)` (third allowed form for this case)
- 9a. Drift acknowledged but deferred (e.g., scope grew during impl; full doc update is its own task):
  1. LLM publishes a `task` event capturing the deferred docs work with revisit-trigger
  2. Evidence becomes `docs drift detected: deferred (task #<N>)` (fourth allowed form for this case)
- 10a. Cycle is planned at 1a as a docs amendment (no code follows):
  1. Docs-first sequencing collapses (no code follows the doc changes)
  2. Phase 3d still runs against the cycle's own diff
  3. Incidental drift fixes within the cycle's docs scope MAY be folded into the same commits; the form classifies cycle *intent at 1a*, not drift-absence
  4. Evidence: `docs refreshed: not applicable (docs-only cycle)` (fifth allowed form; parallel to 8a's `(internal refactor)` parenthetical)
- 11a. Scope-internal pass found no surface drift BUT cycle introduces protocol-level semantics with multi-section reach (Trigger, In/Out, Stakeholders, Preconditions, MSS sub-steps, Extensions, Guard Conditions, Frequency, Priority) → re-run the scope-internal pass at SUBSECTION HEADER granularity: read each subsection of the affected UC and verify the new concept is reflected where logically needed. The discipline is **propagation-completeness verification**, not just drift-presence detection. Operational definition of "deep": every subsection header read; every concept-touchpoint verified against the amendment.

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Attestation published before docs re-read | FAIL: docs-late closure violated |
| `docs refreshed` evidence not in literal form | FAIL: vague evidence rejected |
| Amendment commits land AFTER attestation | FAIL: ordering invariant violated |
| Drift found but no amendment, no skip-justification | FAIL: review observed drift but did not act |
| docs-first skipped on user-visible-behavior change | FAIL: docs-first discipline violated |
| Two-pass audit not performed (one or both passes skipped) | FAIL: 3d discipline violated (per #6191) |

---

## UC12: Plan File Invariant Validation

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** Operator (developer running `evtctl plan`) | **Secondary Actors:** LLM (composes the plan), validate-plan validator
**Priority:** P2 (Medium) — prevents malformed plans landing in stream | **Frequency:** Every `evtctl plan` invocation

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Literal-substring enforcement of README §1c invariants | Position-aware structural validation (commands in correct gate block) |
| 13-marker checklist: gate headings, GATE C STOP, 3c/3d checkpoints, required bash commands, May-I-proceed prompt | Evidence-quality validation (semantic; per #3883) |
| Blocking pre-publish hook on `cmd.plan` | Retroactive replay of legacy plan events |
| Operator-observable bypass (`VALIDATE_PLAN_SKIP=1` with stderr warning) | Silent bypass / no-audit override |
| Runtime smoke-test invocation at completion-gate first line | Defense-in-depth re-validation at completion gate (byte-match per #3881 is strictly stronger) |

### System-in-Use Story

Alex composes a plan via the Tandem Protocol's plan-mode workflow but forgets the GATE C STOP stanza. When Alex runs `evtctl plan ~/.claude/plans/foo.md` at the impl gate, validate-plan refuses publication, listing the missing substring `🛑 GATE C` and pointing to README §1c. Alex amends the plan file, re-runs `evtctl plan`, and the event lands. Later, when Alex deliberately wants to publish a historically-important malformed plan for audit purposes, Alex runs `VALIDATE_PLAN_SKIP=1 evtctl plan bad.md` — the validator prints a stderr warning and lets the event land. The warning makes the bypass observable to anyone reviewing operator logs.

### Stakeholders & Interests

- **Operator** (Alex): wants malformed plans caught BEFORE they land in the audit stream; wants an explicit, observable escape hatch for audit-recovery edge cases
- **LLM**: wants deterministic gate-discipline check it can reason about (no semantic judgment required); wants its plan output validated at the same time the operator validates it
- **Protocol Maintainer**: wants the README §1c checklist mechanically enforced so discipline drift becomes a build error, not silent regression

### Preconditions

- Operator invokes `evtctl plan <file>` from a `tasks.<project>` stream context (current working directory's basename determines the stream)
- `validate-plan` is installed and on PATH (era binary symlink in `~/.local/bin/`)

### Success Guarantee

- A plan event lands in the stream only after validate-plan reports all 13 markers present, OR `VALIDATE_PLAN_SKIP=1` override is set (with stderr warning printed)
- Bypass usage is visible in operator stderr (not silent)

### Minimal Guarantee

- Validation failure produces a list of missing markers on stderr
- No plan event published on validation failure
- Non-zero exit propagates to the operator

### Trigger

Operator runs `evtctl plan <file>`.

### Main Success Scenario

1. Operator invokes `evtctl plan <file>`
2. cmd.plan checks that the file exists and is readable
3. cmd.plan invokes validate-plan with the file path
4. validate-plan reads the file contents
5. validate-plan iterates the 13-marker array and substring-matches each against the contents
6. validate-plan exits 0 (all markers present)
7. cmd.plan invokes era.Publish with the file contents
8. era publishes the plan event and returns the event id
9. cmd.plan prints the published-id to operator's stdout

### Extensions

- 5a. One or more markers absent → validate-plan exits 1 + prints missing markers + substring-only disclaimer + spelling/whitespace hint + README §1c pointer (all to stderr) → cmd.plan returns non-zero → era.Publish NOT called → Operator amends plan file → retry from step 1
- 2a. File not found / unreadable → cmd.plan errors at step 2 (existing behavior); validate-plan is never invoked
- 1a. Operator sets `VALIDATE_PLAN_SKIP=1` (rare audit-recovery case) → validate-plan prints stderr bypass-warning + exits 0 at step 5 regardless of marker presence → publication proceeds at step 7

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| File missing required marker | era.Publish must NOT be called; non-zero exit |
| `VALIDATE_PLAN_SKIP=1` set | Stderr warning printed; era.Publish called; bypass observable in operator logs |
| Legacy plan never re-published | validate-plan never sees it (no retroactive check; future-only enforcement per 1b Q3=a) |
| Completion-gate bash invokes validate-plan as first line | Runtime smoke-test (full code path on known-good file); marker stability already guaranteed by #3881 byte-match below it |
| Marker absent in prose only but present in comments / code blocks | PASSES validation (substring-only; position-aware checking is out of scope per #3883 "narrow invariants") |

## UC13: Plan File Naming Uniqueness

**Scope:** Tandem Protocol | **Level:** Blue
**Primary Actor:** Operator (developer running `/begin` and the impl-gate bash) | **Secondary Actors:** LLM (composes the plan and derives the convention-compliant filename), Claude Code plan-mode (pre-assigns the initial random filename)
**Priority:** P2 (Medium) — reduces but does not eliminate the silent-overwrite class | **Frequency:** Every `/begin` invocation

### In/Out List

| In Scope | Out of Scope |
|---|---|
| Filename-prefix convention computed from `/begin` arguments at 1c Design | Prevention of `EnterPlanMode` overwriting a path that already holds prior content (the Write has already happened by the time impl-gate bash runs) |
| Fail-loud rename block in impl-gate bash (5 explicit arms; no silent loss on src∧dst collision) | Migration of the existing pre-convention plan files in `~/.claude/plans/` |
| Future-only enforcement, consistent with #3883's no-legacy-flag pattern | Era-side `cmd.plan` filename validator hook (deferred to a future task per the operator's mitigation-b choice over mitigation-c) |
| `^[1-9][0-9]*$` regex for the task-ID form; `$(date -u +%Y%m%dT%H%M%S)-$RANDOM` for the no-task-id branch | Subsecond entropy beyond what bash `$RANDOM` provides (~15 bits; collision odds ~1/32768 per matched-second) |

### System-in-Use Story

Alex invokes `/begin 5060`. Claude Code's plan-mode pre-assigns a random filename, `quiet-binding-knuth.md`. The agent, following the /begin skill's naming-discipline section, computes `5060-quiet-binding-knuth.md` as the convention-compliant target and hardcodes the fail-loud rename block into the impl-gate bash. Alex approves the plan and runs the impl-gate bash. The rename completes; `evtctl plan` publishes from the new path.

Three months later Alex starts `/begin 7821` in a fresh session. Claude Code's plan-mode happens to draw `quiet-binding-knuth.md` again — the bare random suffix that #5060 also drew. The agent computes `7821-quiet-binding-knuth.md`. Source and target share the random suffix but differ in prefix; no path collision arises; rename runs; the first cycle's `5060-quiet-binding-knuth.md` remains untouched.

In a later session Alex's plan-mode points at an existing `5060-quiet-binding-knuth.md` because Claude Code re-uses plan files across sessions. The agent's Write at step 6 of MSS overwrites the prior content before any rename can intervene. The rename block detects source equals target and runs as no-op. `evtctl plan` publishes the now-overwritten file. The prior cycle's content survives in the era stream and can be recovered via `era query`, but not from disk. The design.md residual-risks subsection names this branch explicitly.

### Stakeholders & Interests

- **Operator** (Alex): wants the silent-overwrite class reduced; wants filenames that grep and sort predictably; accepts the EnterPlanMode-overwrites residual as out of scope for this cycle
- **LLM**: wants a deterministic naming rule it can compute from `/begin` arguments without consulting external state
- **Auditor**: wants the era stream to remain authoritative for plan history — unchanged by this cycle, which operates only on filesystem paths
- **Protocol Maintainer**: wants the convention encoded in /begin skill text so future drift becomes a file edit rather than a silent regression; accepts that mechanical filename-shape enforcement is deferred

### Preconditions

- Operator invokes `/begin [args]`
- Claude Code's plan-mode pre-assigns an initial filename at some path under `~/.claude/plans/`

### Success Guarantee

- The plan event lands in the era stream with the plan file at the convention-compliant path
- Inter-task collision is eliminated whenever both cycles use the task-ID form (era task IDs are monotonic)
- If both source and target exist at rename time, the bash fails loudly rather than silently losing content

### Minimal Guarantee

- If the operator skips the rename block, behavior degrades to current — no worse than today
- The era stream remains authoritative for plan history in all branches

### Trigger

Operator runs `/begin [args]`.

### Main Success Scenario

1. Operator invokes `/begin <args>`
2. Claude Code plan-mode pre-assigns the initial filename `~/.claude/plans/<initial>.md`
3. Agent reads the /begin skill; parses the first whitespace-separated token of `$ARGUMENTS`
4. If the first token matches `^[1-9][0-9]*$`, the agent sets `<prefix>` to that integer; otherwise `<prefix>` becomes `$(date -u +%Y%m%dT%H%M%S)-$RANDOM`
5. Agent composes `<prefix>-<random>.md` where `<random>` is the basename of the pre-assigned path with the `.md` extension stripped
6. Agent writes plan content to the pre-assigned path (plan-mode forbids writing elsewhere); hardcodes the fail-loud rename block and the convention-compliant filename into impl-gate and completion-gate bash
7. Agent exits plan mode, surfaces the plan and impl-gate bash, awaits "proceed"
8. Operator approves; impl-gate bash runs the rename: if source exists and target does not, `mv`; if both exist, fail loudly; otherwise no-op
9. Impl-gate bash continues with `evtctl plan ~/.claude/plans/<convention-compliant>.md`; the plan event publishes from the new path

### Extensions

- 3a. /begin has no arguments → step 4 takes the timestamp+entropy branch
- 4a. /begin's first token does not parse as a positive integer (free-form description, `0`, negative, `task-5060`, leading-plus, quoted-numeric) → step 4 takes the timestamp+entropy branch; the /begin skill text names this fallback as intentional, not error
- 6a. The plan-mode system reminder format changed and the agent cannot parse the pre-assigned path from it → agent falls back to `ls -1t ~/.claude/plans/*.md | head -1`
- 8a. Operator skips or omits the rename block → file stays at the pre-assigned path; the collision class returns for this cycle; the era stream still records the plan event
- 8b. Both source and target exist at rename time (distinct paths, both occupied) → bash fails loudly; operator manually resolves with `rm <dst>` for intentional replan or `mv <dst> <dst>.bak` to preserve; re-runs impl-gate bash
- 8c. Source equals target (the pre-assigned path is already convention-compliant — bootstrap-exception cycle, or a same-task replan that re-uses the slot) → no-op branch; bash falls through to evtctl plan
- 8d. `mv` fails (cross-device move, permission denied, ENOSPC) → `set -euo pipefail` aborts the gate; operator sees the mv error on stderr, resolves, re-runs (the no-op branches make re-entry idempotent)
- 8e. EnterPlanMode pre-assigns an existing convention-compliant file from a different prior cycle → the agent's Write at step 6 has already overwritten prior content before the rename block runs; rename detects source equals target and runs as no-op; prior content survives in the era stream but not on disk; the convention does not close this branch

### Guard Conditions

| Condition | Expected Behavior |
|---|---|
| Existing pre-convention plan files in `~/.claude/plans/` | Untouched (future-only enforcement) |
| Plan-immutability byte-match (#3881) | Holds — `mv` preserves bytes |
| validate-plan (#3883) | Reads the convention-compliant path after rename; marker check unaffected (path-agnostic) |
| Bootstrap exception (#5060's own plan file) | Grandfathered at `greedy-churning-lerdorf.md`; does not extend to other cycles |


