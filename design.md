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

Plan file = HOW (approach, changes). Contract = WHAT (criteria) — published to Era via `evtctl contract` at the Implementation Gate, not stored in the plan file.

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
- `/grade`: copy a self-contained adversarial grading request to clipboard for user to service with external resources (mandatory at §1d.5 before ExitPlanMode; manual at any gate)

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
