# Tandem Protocol Design

## Cross-Cutting Principles

**Main success path only.** Protocol covers the happy path. Exceptional cases omitted — Claude can reason through these without explicit guidance.

**Diagrams show structure; text explains sequences.** Keep mermaid clean. Diagrams are the shared visual language for state transitions between developer and LLM.

**Era is the single event store.** All events published via `evtctl` commands (which call `era publish`), not direct `era publish`. This ensures stream names derive from PROJECT_ROOT, eliminating the `<project>` variable. No local log files.

**Executable syntax for gate invariants.** Gate actions use `evtctl` commands — executable bash that Claude runs directly. This achieves ~100% compliance because it's code Claude executes, not instructions Claude interprets. Behavioral instructions (like "quote verbatim") achieve ~80% compliance. The protocol uses executable syntax for critical invariants (gate commands, stop conditions) and prose for guidance (investigation, clarification). When the README names specific commands at gates, use "executable bash" language to signal these are runnable actions, not descriptions.

**Denormalized README.** Each section is self-contained — no cross-references ("from 1c", "see above"), no inference at reading time. Rationale: LLM compliance drops when a section requires jumping to another section to understand its meaning; denormalization also survives context compaction where referenced sections may be lost.

**Claims are event-sourced.** Derived from the stream, not stored as mutable state. `task-audit` reconciles task/done/claim/unclaim events to compute current state.

**Behavioral vs mechanical enforcement.** Halt instructions to the agent are prose (~80% compliance); precondition checks at gate time are executable bash (~100%). The two compose: prose tells the agent to stop, bash makes the gate fail-closed if the precondition is violated.

**Context-space efficiency.** Protocol documents (README, design.md, use-cases.md, normative template text) prefer tables/lists, then mermaid (in README only), then code blocks, then prose. Plans are not in scope — their length is cycle-dependent. Mechanical enforcement is deferred to future validation tooling.

---

## Plan Mode (UC2, UC3)

### Content Distinction

Plan file = HOW (approach, changes). Contract = WHAT (criteria) — published to Era via `evtctl contract` at the Implementation Gate, not stored in the plan file. Plan file post-1d.5-final-exit is immutable until explicit `/loopback` regression; see §Plan immutability for the lifecycle rules.

| Content Type | Belongs In | Mechanism |
|---|---|---|
| Approach, methodology, research notes | Plan file (`~/.claude/plans/`) | Written during plan mode |
| Scope, success criteria, deliverables | Contract event | `evtctl contract` at Implementation Gate |

### Tool Mapping

| Action | Tool/Mechanism |
|---|---|
| Enter plan mode | `EnterPlanMode` |
| Write plan | Edit `~/.claude/plans/<name>.md` |
| Exit plan mode | `ExitPlanMode` |
| Publish contract | `evtctl contract <<'EOF' ... EOF` (stdin via heredoc) at Implementation Gate |

### Entry Sequence (Step 1c)

1. `EnterPlanMode` (creates `~/.claude/plans/<name>.md`)
2. If existing plan (system-reminder shows plan content):
   - Quote plan verbatim (no summarizing)
   - Grade analysis: "Do I understand this?" — FIRST
   - Grade plan quality: "Is this sound?" — SECOND
   - Wait for user direction before proceeding — BLOCKING
3. Otherwise: create new plan
4. On approval: `ExitPlanMode`, execute Implementation Gate bash block

### Integration Points

| Protocol Step | Action |
|---|---|
| Step 1b (Clarify) | MUST ask at least one question — user controls scope |
| Step 1c (Design) | Enter plan mode, check for existing plan |
| Step 1d (Present) | Quote verbatim, grade, wait for direction, validate, exit |
| Step 2 (Impl Gate) | Publish contract via `evtctl contract` |

---

## Line References (UC5)

**Problem:** Observed failures where line numbers become stale after edits but aren't updated.

**Mechanism:** Step 1a includes "note line refs" — a reminder that line numbers noted during investigation will drift during implementation. The system should re-read affected sections before presenting results at step 3b.

| Protocol Step | Action |
|---|---|
| Step 1a (Investigate) | Note line refs (with caveat they'll shift) |
| Step 3a (Execute) | After edits, verify line refs still accurate |
| Step 3b (Present) | Present with corrected references |

---

## Grading & Lesson Capture (UC6, UC9)

### Grading Model

At either gate, if there are guides for compliance, issue `/c` first before the presentation step (1d or 3b). Auto `/i` cycles run ≥2 passes (cap 3 unless each additional pass surfaces a new defect class) before presentation; full rule in README Gate Grading.

- `/i`: find opportunities to improve and execute on them
- `/c`: grade vs guides + fix; ask "Can I fix this now?" — yes → fix, no → capture in guide
- `/grade`: copy a self-contained adversarial grading request to clipboard for user to service with external resources (required at §1d.5 before ExitPlanMode for standard/high-risk tiers; waived for trivial; manual at any gate)

### Tier classification (UC #3880)

**Waterfall application:** at §1a Tier classification, the agent evaluates eligibility rules in order — drop → trivial → high-risk → standard (default). The first matching rule wins. High-risk overrides standard when its predicate fires (multi-repo / public API / data migration); trivial wins over standard when its predicate fires (single-file ≤20 lines + no API).

**Why the LOC thresholds are soft:** the ~20-line cutoff for trivial and the ~100-line cutoff for drop (#5515) are guidelines, not strict cutoffs. Operator judgment + 1b clarify finalize. The hard rules are categorical:
- multi-repo → high-risk MUST
- public API change → high-risk MUST
- data migration → high-risk MUST
- drop's "no UC implications" — categorical (UC changes always merit Tandem)

**Protocol-governance amendments are intentionally NOT in the high-risk predicate.** A docs-only cycle that changes every future cycle's ceremony (like #4154 or #3880 itself) is arguably higher operational risk than a small public API tweak, yet remains standard tier under current rules. This is a deliberate scoping choice (the predicate captures implementation-shaped risk, not protocol-impact-shaped risk); the operator can still self-classify a governance amendment as high-risk via §1b override.

**Mid-cycle escalation:** when post-classification investigation reveals a high-risk predicate firing (e.g., the cycle actually touches a shared library; a public API change was missed), the agent escalates tier and applies the new scaffolding from that point. Log `evtctl interaction "/tier-escalate <from>-><to>: <reason>"`. Downgrades are forbidden mid-cycle (prevents an agent from claiming a tier change to skip /grade or /i after starting). Escalation is asymmetric: more ceremony OK, less ceremony NOT OK.

**Escalation applies prospectively only**: previously omitted high-risk-only events (per-phase-entry `/phase` events, decision-point `/decision` events) are NOT backfilled when a cycle escalates from standard to high-risk. A late-escalation cycle's ledger is structurally distinct from an early-high-risk cycle's ledger — the partial-ledger pattern is intentional and audit-visible (auditors can distinguish "events absent because cycle was standard at the time" from "events absent because operator failed to log them" by reading the `/tier-escalate` event). Backfill would reconstruct event content without reconstructing the actual phase discipline the events are supposed to evidence; that would create audit-trail dishonesty.

**Evidence ledger (high-risk tier): stream-based, NOT file-based.** High-risk cycles publish:
- `evtctl interaction "/phase <id> entered: <one-line summary>"` at each phase entry (1a, 1b, 1c, 1d, 1d.5, 3a, 3b, 3c, 3d)
- `evtctl interaction "/decision: <choice> chosen over <alternative> because <rationale>"` at major decision points
- Existing event types (contract / plan / claim / complete / done / interaction / loopback) continue as canonical record

The "evidence ledger" name describes the stream-aggregated view across these events — there is no new file type. An `era query session.<project> 'type = "interaction" AND payload ~ "/phase"'` reconstructs the ledger view at audit time.

**Trivial-tier exemptions complete list:**

| Step | Trivial behavior |
|---|---|
| §1a + §1b | Collapsed into single "Quick scope" step; investigation prose minimal; mandatory question waived if no uncertainty |
| §1c | Plan with minimum sections only (Contract criteria + Implementation Gate bash + Completion Gate bash + Verification); no Context, no scope justification, no /i log |
| §1d Auto `/i` | Exempted (manual `/i` still permitted) |
| §1d.5 `/grade` | Exempted (manual `/grade` still permitted) |
| §3c Khorikov | N/A (trivial cycles are typically too small for SUT classification) |
| §3d docs refresh | Still runs (induced drift can occur in any change) |

Trivial-tier rationale: the eligibility predicate (single-file ≤20 lines, no API contract) is itself a strong proxy for "few defect classes adversarial review would catch," matching the goldilocks principle (era memory `41d659175095`). For changes large enough to merit /grade, the cycle is no longer trivial.

### Plan immutability (UC #3881)

The plan file at `~/.claude/plans/<plan-name>.md` is immutable post-1d.5-final-exit until explicit `/loopback` regression. Four reinforcing reasons:

- **Stream-as-source-of-truth alignment.** The `evtctl plan` event captures plan content at the cycle's approval moment. Silent file edits after that create divergence: either file is truth and stream is stale, or stream is truth and file is misleading. Immutability picks: stream is canonical; file matches stream byte-for-byte until explicit regression. Resolves the contradiction.
- **Explicit regression as audit signal.** When plan needs to change, the agent fires `/loopback <from>-><to>: <reason>` — a visible stream event. Auditors reconstruct change history from the chain `plan event A → /loopback event → plan event B`. With silent mutation, auditors see only the final plan; the journey is lost.
- **Prevents subtle scope drift.** Mutable plans invite mid-impl rationalization ("this was always part of the plan"). Immutability + explicit regression forces the agent to admit: "the plan changed; here's the new contract." Scope creep stops being free.
- **Architecture-artifact reuse.** A future operator reading a historical plan as a design reference reads a stable contract, not a living document re-edited five times since impl. The plan's value as a reusable pattern depends on freezing at a known moment.

Plan-immutability is the application of stream-as-source-of-truth (Tier 1 axiom) to the plan-file artifact. Parallel patterns: contract-supersession via the `supersedes` chain (Tier 1 #4070); phase-regression-event-logging via `/loopback` (Tier 2 #3882); /tier-escalate via `/tier-escalate` event (Tier 3 #3880). The protocol's consistent discipline: structural changes leave audit-visible event traces; silent file mutation undermines the stream-canonical principle.

**Mid-cycle plan supersession:** when `/loopback` regression to plan mode fires, both the plan event AND (if criterion topology changed) the contract event publish with `"supersedes": <prior-event-id>` field per Tier 1 #4070 chain pattern. Mechanical enforcement of the supersedes-field schema is tracked in #5705; the protocol prescribes the pattern even while the validator-level enforcement is pending.

**Full regression mechanics (moved from README §1d.5 per #6249 slim-down).** Phase regression to plan mode is supported via supersession chains. If post-impl investigation (3a/3b/3c/3d) reveals the plan needs reshape, the agent fires an explicit `/loopback <impl-phase>->1c: <reason>` interaction event (per Tier 2 #3882 phase-regression discipline). This re-enters plan mode; plan file becomes mutable again. The agent revises the plan, runs another 1d → 1d.5 cycle, then at the new 1d.5-final-exit publishes:
- `evtctl plan ~/.claude/plans/<plan-name>.md` with `"supersedes": <prior-plan-event-id>` — new plan event supersedes prior
- `evtctl contract` with `"supersedes": <prior-contract-event-id>` if criterion topology changed (renaming / splitting / merging)

The stream chain — prior plan/contract events → `/loopback` regression event → new plan/contract events — is audit-visible. Plan file re-freezes at the new 1d.5-final-exit.

**Alternatives without full re-entry** (for smaller adjustments):
- **(a) scope-fold** in-cycle correction within existing criterion topology (interaction events; no supersession)
- **(b) defer** affected criteria to follow-up task (`evtctl task` + `dropped` status)
- **(c) start a new plan cycle** with a fresh `<plan-name>.md` (file collision per #5060 acknowledged) for fundamentally different work

Re-entry via `/loopback` + supersedes-chain is for genuine plan-reshape regression; alternatives cover lighter cases.

**Prospective-only escalation semantics:** when regression fires, the new plan covers only forward-looking work. Already-attested criteria stay attested under the prior contract; the new contract only carries criteria for the regression-induced work. Marker-presence in re-published plans is mechanically enforced by validate-plan (per "validate-plan invariants — mechanism" below); plan-event-byte-match against the file remains a non-blocking check in completion-gate verification today.

### Docs-first commit ordering — rationale (moved from README §3a per #6249 slim-down)

Docs land first so the contract criteria (already published at the impl gate) can be evaluated against doc artifacts at impl-review time, not against still-being-typed code. Reviewers reading the diff see the contract → use case → design → code chain, in that order. Drift between code and docs caught during 3a folds into Commit N+1 (still docs-first within the cycle); drift caught at 3d folds in there.

### Criterion rename via republish-contract — rationale (moved from README §3b per #6249 slim-down)

If `/i` reveals a criterion needs renaming, prefer **(b) publish a corrected contract before completion** over (a) keeping the attestation's name verbatim with an evidence note. Republishing leaves an explicit contract→contract chain in the stream (the later contract supersedes the earlier); verbatim-preservation hides the divergence in evidence prose, which audits and graders cannot parse. The cost of republishing is one extra `evtctl contract` event; the cost of verbatim-with-prose is that future cross-stream reconciliation has to do payload archaeology to decide whether an unmatched contract is WIP, superseded, or abandoned. Republish.

### GATE C STOP stanza — rationale (moved from README §1c per #6249 slim-down)

The stanza is a behavioral safeguard, not a mechanical enforcement mechanism — its purpose is execution-time locality: the halt instruction sits adjacent to the executable bash in the artifact the agent traverses. Mechanical plan-file invariants are now enforced by `validate-plan` as a blocking pre-publish hook on `evtctl plan` (see "validate-plan invariants — mechanism" below). Backward compatibility: legacy plans without the stanza or without the 3c/3d checkpoints are valid for in-flight cycles already past 1d; new plans MUST include them (and any `evtctl plan` republish will be rejected unless markers are present).

### validate-plan invariants — mechanism (UC #3883)

`validate-plan` is the mechanical enforcer for the README §1c pre-ExitPlanMode checklist. It runs as a **blocking pre-publish hook** on `evtctl plan` (asymmetric with `validate-attestation`'s post-publish non-blocking model) and also as the first line of completion-gate bash (runtime smoke-test). Source: `~/projects/era/bin/validate-plan`.

**The 13-marker list** (canonical executable mirror; README §1c is the protocol-level source of truth — this list mirrors as authoring-time reference):

1. `## At Implementation Gate`
2. `## At Completion Gate`
3. `🛑 GATE C`
4. `May I proceed?`
5. `Phase 3c Khorikov`
6. `Phase 3d Documentation Refresh`
7. `evtctl contract`
8. `evtctl plan`
9. `evtctl claim`
10. `era store`
11. `evtctl complete`
12. `evtctl done`
13. `git commit`

**Why literal substring-match only** (per #3883: "Don't try to validate evidence quality — semantic and unenforceable via grep"). Substring-match is intentionally permissive: a plan with markers inside HTML comments, fenced code blocks, or quoted prose passes validation. The trade is cheap deterministic checks vs full structural parser. The latter belongs in #5013 (doc-lint), not here.

**Why blocking (asymmetric with validate-attestation)**:
- Plans precede work (10s-100s of operator-hours per cycle); a bad plan = wasted cycle. Refusing up front is cheap.
- Attestations follow work (audit artifact post-hoc); non-blocking lets the artifact land for later debugging without erasing the audit trail.
- **Counter-scenario** (audit-recovery): an operator may want to publish a deliberately-malformed plan to the stream for historical/forensic purposes. Blocking-by-default would erase this artifact. **Mitigation**: env-var override `VALIDATE_PLAN_SKIP=1` bypasses validate-plan and prints a stderr warning ("WARNING: validate-plan bypassed by VALIDATE_PLAN_SKIP=1; plan published without invariant validation."). Default-secure; opt-in but observable escape hatch (not silent).

**Why no `--legacy` flag**: future-only enforcement. In-flight legacy plans don't re-invoke `evtctl plan`, so they're naturally exempt. `/loopback` cycles that re-publish a legacy plan must first amend it to conform.

**Why a self-referential marker `validate-plan` was rejected** (initial design considered a 14th marker requiring the plan to invoke validate-plan at completion-gate time; dropped):
- The completion-gate first-line `validate-plan` call IS recommended (per #3883's task description) but its purpose is **runtime smoke-test**, NOT mechanical re-validation.
- The plan-immutability byte-match (per #3881) is strictly stronger than any second validate-plan invocation: byte equality between plan file and plan event implies marker equality.
- Requiring the literal string `validate-plan` as a plan-file marker passed via prose occurrence in template documentation, not actual gate invocation — the implemented invariant did not match the claimed invariant.

**Acknowledged enforcement gap**: with that marker dropped, there is **no mechanical enforcement** that completion-gate bash actually invokes `validate-plan`. Operators can delete the line from their plan template and validation still passes. This gap is intentional — mechanical enforcement of "first-line invocation" requires position-aware parsing (impl-gate-section vs completion-gate-section vs prose), which is semantic and out of scope per #3883's "narrow invariants only" mandate. Pre-publish validation (the load-bearing check) is unaffected. The completion-gate invocation is operator discipline + runtime smoke-test; not a load-bearing enforcement point.

**Runtime smoke-test honest framing**: the completion-gate `validate-plan ... || exit 1` line is a **runtime smoke-test**, not "install smoke-test" or "PATH check." It exercises the full validate-plan code path (read file, iterate markers, exit 0) on a known-good file. Alternative `command -v validate-plan` would only check PATH lookup. The runtime invocation is slightly stronger: catches binary-exists-but-broken cases (permissions, dynamic-linker, dependency missing). Operational value is admittedly low (cost ~10ms; covers a rare failure mode); we honor #3883's task description literally because the alternative is to drop the invocation entirely, which contradicts the task spec.

**Cross-repo rollout ordering**:
- Land tandem-protocol commits BEFORE era commits in calendar time
- Rationale: docs lead implementation. README documenting "this is enforced" with the era binary not yet present is informational; era binary enforcing markers with the README not yet documenting them locks operators out without explanation
- **Mechanical guard**: the completion-gate bash includes an assertion between the tandem-protocol push and the era commits:
  ```bash
  cd ~/projects/tandem-protocol
  git fetch origin
  git merge-base --is-ancestor HEAD origin/main || { echo "tandem-protocol HEAD not on origin/main; push before era commits"; exit 1; }
  ```
  Prevents operator drift on the ordering rule.
- Rollback path: if era commits land but tandem-protocol README is unreachable to operators, they see "validate-plan" errors with old README templates. Override: `VALIDATE_PLAN_SKIP=1` for immediate relief; `git revert` on era binary commits is permanent.

**Marker-list synchronization discipline**:
- README §1c is the protocol-level spec
- This section mirrors as authoring-time reference
- validate-plan's bash array is the executable source
- **All three MUST be amended in the same commit** when adding/removing required elements
- **Mechanical protection (partial)**: `test_validatePlan_markerArrayIsCanonical` golden-list test protects the bash array from silent change — if anyone adds/removes/edits a marker, the test fails until the test's hardcoded expected list is also updated. Forces explicit attention.
- **Sync against README §1c is NOT yet mechanically protected**: a CI lint that extracts §1c's marker list and diffs against the bash array remains pending — tracked as #5013 (existing pending task). For now: 3d-audit touchpoint discipline + the golden-list test catch the executable-side; README-side drift is operator discipline.
- Add to the **3d audit touchpoint checklist**: "if §1c changed, the validate-plan bash array AND the golden-list test must be updated together."

**Failure-mode UX**: the validator's failure message explicitly states the limitation ("literal substring not found anywhere in file") plus a spelling/whitespace hint ("exact substring match — check spelling, capitalization, whitespace"), so operators don't assume deeper validation or chase wrong-cause debugging on near-misses.

### Reconciliation audit — interpreting unmatched contracts (moved from README §"Stream as source of truth" A4 per #6249 slim-down)

Counting raw `contract` vs `complete` events per stream is **not** a substitute for the criterion-name-superset join — completions can carry added criteria, supersede earlier contracts, or be republished, so the counts diverge in both directions without indicating WIP.

An unmatched contract is a *candidate* for WIP, not a confirmation — historical reasons it appears unmatched include:
- **Criterion-rename supersedure** (see "Criterion rename via republish-contract — rationale" above): a later contract on the same topic uses corrected criterion names; the earlier contract becomes unmatched
- **Early bootstrap contracts** that predate strict attestation
- **Spurious publishes with empty `criteria`** (validator skipped them)

Reconcile each unmatched contract against:
- (i) a later contract on the same topic with renamed criteria
- (ii) commits that delivered the named work without a `complete` event
- (iii) `era search` for memories recording the cycle's outcome

The audit narrows the search space; the operator decides.

### Two-pass 3d audit (UC #6191)

The two passes (scope-internal first, scope-external second) serve distinct purposes:
- **Scope-internal:** propagation-completeness verification — when the cycle's amendment touches a concept, has it propagated through all sections of every affected doc? UCs have multiple normative sections (Trigger, In/Out, Stakeholders, Preconditions, MSS, Extensions, Guard Conditions, Frequency, Priority); README has multiple sub-steps; design.md has rationale subsections + tables + test plans. A single-pass surface re-read can miss broader-section propagation gaps.
- **Scope-external:** induced-drift detection — the cycle's amendment may make transitively-stale content in adjacent docs (FEATURES.md, evolution.md, guides, project-specific design docs) the cycle did NOT modify. The scope-external scan catches transitively-induced drift.

**Empirical anchor:** Tier 3 #3880 (tier system introduction) ran the original single-pass 3d audit on README + use-cases.md + design.md and found no drift, then user directive "we always find stuff" triggered a deeper second pass on the docs already being modified — which found UC9 broader sections (System-in-Use Story, MSS, Trigger, Preconditions, In/Out List, Frequency) still describing standard-tier workflow as if universal. Extension 2d (the cycle's planned UC9 touch) alone hadn't propagated broadly enough. Surfaced in completion memo `432b32e91947`.

**Two interaction events per cycle** (vs one combined event): scope-internal failures (propagation gap) and scope-external failures (induced drift) have distinct remediation paths:
- Scope-internal failure → fold an in-cycle amendment to the affected UC sections (the cycle's primary amendment expanding within existing criterion topology, per #3881 plan-immutability alternatives)
- Scope-external failure → file a follow-up task for adjacent-doc alignment (per Tier 3 #4154's #5971 pattern) OR fold per topical-boundary rule

Distinct event types make audit-time triage easier; a single combined event would force the auditor to parse a structured payload to determine which pass failed.

### Lesson Capture

The actionability test is a simple decision rule. Claude can reason through the routing (which guide, etc.) without explicit protocol guidance. Encoding the decision point is sufficient.

**Actionability test:** "Can I fix this now?" means ALL of:
- Within current contract scope
- Fixable in this session
- Not requiring user decisions not yet made
- Not a process/methodology improvement (those go to guides)

**YES → grade deduction + fix.** **NO → capture lesson in guide:**

| Lesson Type | PI Stage | Target Guide |
|---|---|---|
| "Should have explored X" | Plan | planning-guide.md |
| "Misunderstood Y" | Plan | planning-guide.md |
| "Better approach Z" | Plan | planning-guide.md |
| Code quality patterns | Implement | (domain-specific guide) |
| Protocol compliance | (meta) | protocol-guide.md |

**Lesson event format:** `evtctl interaction "/c -> lesson: [title] -> [guide]"`

---

## Event Logging (UC7)

### Event Types and Commands

| Type | When | Command | Format |
|---|---|---|---|
| Contract | Implementation Gate | `evtctl contract <<'EOF' ... EOF` (stdin) | JSON: phase + criteria array |
| Plan | Implementation Gate | `evtctl plan <file>` | Plan file contents |
| Task | Implementation Gate | `evtctl task "desc"` | JSON: description |
| Claim | Implementation Gate | `evtctl claim <id> <name>` | JSON: ref + claimer |
| Interaction | `/i` `/c` `/grade` at gates | `evtctl interaction "desc"` | JSON: description |
| Completion | Completion Gate | `evtctl complete <<'EOF' ... EOF` (stdin) | JSON: criteria + statuses |
| Task-done | Completion Gate | `evtctl done <id> "evidence"` | JSON: refs + description |
| Session | Both gates | `era store --type session -t "..." <<'EOF' ... EOF` (stdin) | Session summary: objective, decisions, deliverables, lessons, decision points and rationales |

### Contract/Completion Format

**Contract:** `{"phase":"...", "criteria":["name1","name2"]}`

**Attestation:** `{"criteria":[{"name":"...","status":"...","evidence":"..."},...]}`

**Statuses:** `delivered` (+evidence), `dropped` (+reason), `added` (+evidence)

`evtctl complete` validates that every contract criterion appears in the attestation.

### Example Event Flow

```bash
evtctl contract <<'EOF'
{"phase":"Phase 1 - auth","criteria":["middleware","tests","docs"]}
EOF
evtctl task "Phase 1 - auth"
evtctl claim <task-id> claude
# ... implementation ...
evtctl interaction "/i -> missing edge case, added"
evtctl interaction "/c -> naming violation per Go guide, fixed"
evtctl complete <<'EOF'
{"criteria":[{"name":"middleware","status":"delivered","evidence":"auth.go:45"},{"name":"tests","status":"delivered","evidence":"auth_test.go:12"},{"name":"docs","status":"dropped","reason":"deferred"}]}
EOF
evtctl done <task-id> "Phase 1 complete"
```

### Docs-refreshed evidence form (UC11)

The `docs refreshed` criterion in a contract must carry, at attestation time, one of these literal forms:

| Form | When |
|---|---|
| `docs drift detected: yes (<SHA>[, <SHA>...])` | Drift found; one or more amendment commits, comma-separated (precedent era #3826) |
| `docs drift detected: no (reviewed: README, use-cases.md, design.md)` | All three docs re-read; no drift |
| `docs refreshed: not applicable (internal refactor)` | Cycle is pure-internal-refactor (no user-visible or design change) |
| `docs refreshed: not applicable (docs-only cycle)` | Cycle was planned as docs-only at 1a; form indicates plan-time intent (cycle classification), not the absence of drift. Incidental drift fixes within the cycle's docs scope MAY be folded into the same commit — this form is about whether the cycle is *primarily* a docs amendment, not whether any drift was found en route. Boundary: incidental fixes must be directly exposed by the cycle's primary amendment (adjacency, induced inconsistency, stale enumeration that touches the same lines); opportunistic repo cleanup unrelated to the primary amendment is out of scope and belongs in its own cycle. |
| `docs drift detected: deferred (task #<N>)` | Drift acknowledged; full update deferred to task <N> |

Vague forms ("docs refreshed", "n/a", "ok") are rejected. The literal form is the auditable friction that prevents docs-late closure from becoming a rubber stamp.

---

## Task Claiming (UC10)

### Task Lifecycle

| Command | Event Type | Purpose |
|---|---|---|
| `evtctl task "desc"` | `task` | Create task, returns ID |
| `evtctl claim <id> <name>` | `claim` | Assign task to agent |
| `evtctl unclaim <id>` | `unclaim` | Release assignment |
| `evtctl done <id> "evidence"` | `task-done` | Complete task (releases claim) |

### Inspection

| Command | Action |
|---|---|
| `evtctl open` | List open (uncompleted) tasks |
| `evtctl claims` | List active claims (on open tasks only) |
| `evtctl audit` | Full reconciliation: total, matched, open |

### Reconciliation Rules

State derived from event stream:
- `task` → task exists (open)
- `task-done` with `refs` → task completed (removes from open, releases claims)
- `claim` with `refs` → task claimed by `claimer`
- `unclaim` with `refs` → claim released

Last-writer-wins for claims. `evtctl claim` warns if already claimed but publishes anyway. Done tasks filter out of `evtctl open` and `evtctl claims`.

---

## Docs-First AND Docs-Late Closure (UC11)

### Discipline

| When | Action |
|---|---|
| Before impl (1c) | Update use-cases.md and design.md (docs-first) for any user-visible behavior or design change |
| At Completion Gate, BEFORE `evtctl complete` | Re-read README + use-cases.md + design.md (docs-late closure) |
| If drift found | Amend, commit ("docs: post-impl drift fix"), push BEFORE attestation |
| Attestation evidence | Literal form on `docs refreshed` criterion (see Event Logging above) |

### Required Ordering

```
review → amend (if needed) → commit → push → evtctl complete
```

Attestation MUST NOT be published while any normative doc is known to be stale. The amendment commit's SHA becomes the evidence on the `docs refreshed` criterion when drift was found.

### Scope Exemption

Pure internal refactors (rename a private helper, reformat a comment) skip both docs-first and docs-late. The plan template's completion-gate docs-review sequence and UC7's Guard Conditions row enforce ordering for non-exempt cycles.

---

## Behavioral Test Cases

| ID | UC | What Protocol Must Contain | Grep Pattern |
|---|---|---|---|
| T0.1 | — | No cross-references in README | NOT `from [0-9][a-d]\|see step\|see section\|see above\|see below` |
| T2.1 | UC2 | Plan file = HOW | `[Pp]lan.*HOW\|HOW.*plan` |
| T2.2 | UC2 | Contract = WHAT | `[Cc]ontract.*WHAT\|WHAT.*[Cc]ontract` |
| T2.3 | UC2 | Plan file location | `plans/` |
| T2.4 | UC2 | evtctl contract at gate | `evtctl contract` |
| T2.5 | UC2 | Must ask at least one question at 1b | `MUST ask.*question\|at least one question` |
| T3.1 | UC3 | Quote verbatim guidance | `[Qq]uote.*verbatim\|VERBATIM` |
| T3.2 | UC3 | Analysis grade before plan grade | `grade.*analysis\|Do I understand` |
| T3.3 | UC3 | BLOCKING wait for direction | `STOP.*user\|wait.*direction` |
| T5.1 | UC5 | Line reference guidance | `line ref` |
| T6.1 | UC6 | Actionability test at grading | `[Cc]an I fix this now` |
| T6.2 | UC6 | Non-actionable → guide routing | `capture.*guide` |
| T7.1 | UC7 | evtctl contract at Implementation Gate | `evtctl contract` |
| T7.2 | UC7 | evtctl complete at Completion Gate | `evtctl complete` |
| T7.3 | UC7 | evtctl interaction at grading | `evtctl interaction` |
| T7.4 | UC7 | No local log files | NOT `plan-log` |
| T9.1 | UC9 | Grading commands at gates | `(/grade\|/i\|/c).*fix` |
| T9.2 | UC9 | Grading loop in overview diagram | `mermaid` |
| T9.3 | UC9 | evtctl task in template | `evtctl task` |
| T9.4 | UC9 | evtctl done in template | `evtctl done` |
| T9.5 | UC9 | evtctl claim in template | `evtctl claim` |
| T9.6 | UC9 | No direct era publish in templates | NOT `era publish` in gate blocks |
| T10.1 | UC10 | evtctl claim in plan template | `evtctl claim` |
| T10.2 | UC10 | evtctl done at Completion Gate | `evtctl done` |
| T11.1 | UC11 | GATE C STOP stanza in plan template | `🛑 GATE C — Before executing` |
| T11.2 | UC11 | Docs-review precedes evtctl complete in template | `docs drift detected.*\nevtctl complete` (multiline / awk) |
| T11.3 | UC11 | Literal evidence form enforced | `(docs drift detected\|docs refreshed):` (both prefixes — `not applicable` forms use `docs refreshed:`; yes/no/deferred use `docs drift detected:`) |
