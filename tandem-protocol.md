# Tandem Protocol Guide

**For:** AI agents working on multi-phase projects with the user
**Purpose:** Prevent premature advancement, ensure quality gates, maintain audit trail

---

## Why This Protocol Exists

Prevents goalpost moving, premature advancement, missing deliverables, and false completion. Key principle: User must explicitly approve each phase before logging/committing/advancing.

---

## The 5-Step Protocol (Plus Step 0)

### Step 0: Check for Evidence Files (Protocol Violation Detection)

**What:** At the start of work, check if any evidence files exist from previous incomplete work.

**Why this step exists:** Evidence files are temporary working documents (Steps 1-4 only), deleted in Step 5c after being appended to plan-log. If evidence files exist at Step 0, previous phase was not completed properly (protocol violation - Step 5c not executed).

**When to perform:**
- At start of every work session
- After conversation compaction/restoration
- When resuming work on a project

**Mechanism:**

1. **Check for evidence files:**
   ```bash
   ls -1 ./*-completion-evidence.md ./*-evidence.md 2>/dev/null | wc -l
   ```

2. **If NO evidence files exist:**
   - ✅ Good - previous work completed properly
   - Proceed to Step 1 for new phase

3. **If evidence files exist:**
   - ⚠️ **PROTOCOL VIOLATION DETECTED**
   - Previous phase was incomplete (evidence not appended to plan-log and deleted)
   - Tell user:
     ```
     Found N evidence file(s) from incomplete work:
     [list files]

     This indicates Step 5c was not completed (evidence not appended to plan-log).

     Options:
     1. Complete the interrupted phase (review evidence, append to plan-log, delete file)
     2. Abandon the work (delete evidence file as cleanup)
     3. Investigate what happened (read evidence file to understand state)
     ```
   - **WAIT for user decision**

4. **If user chooses to complete (Option 1):**
   - Review evidence file content
   - Verify it's marked "APPROVED" (if not, this was abandoned at Step 4)
   - Execute Step 5c: Append to plan-log and delete evidence file
   - Then proceed to next phase

5. **If user chooses to abandon (Option 2):**
   - Delete evidence file:
     ```bash
     rm -f [evidence-file.md]
     ```
   - Confirm: "Evidence file deleted. Previous work abandoned. Ready to start new phase."
   - Proceed to Step 1 for new phase

**This enforces:**
- Protocol compliance (Step 5c must delete evidence files)
- Clean workspace (no stale files between phases)
- Evidence lifecycle discipline (temporary during Steps 1-4, appended and deleted in Step 5c)

---

### Step 1: Plan Validation and Approval

**What:** Before starting implementation, validate understanding of the plan and get approval to proceed.

**Why this step exists:** Catches misunderstandings before wasting tokens, validates target files/insertion points/approach, creates accountability checklist upfront, and provides user checkpoint to redirect before investment.

**Step 1 Deliverables:**
- Present your understanding of the plan to user (with specific targets, line numbers, concrete actions) and get user confirmation that understanding is correct
- Create evidence file documenting the validated plan with completion criteria
- Create TodoWrite structure (Steps 1-5 for current phase)
- Ask "May I proceed?" and await approval

**Actions:**

1. **Read the plan** (from plan-log or verbal discussion)
2. **Identify targets precisely:**
   - Which files will be modified? (full paths)
   - Which line numbers for insertions?
   - Which sections will change?
3. **Present understanding to user for validation:**
   - "I understand the plan as: [summary]"
   - "Target files: [list with paths and line numbers]"
   - "Approach: [specific actions]"
   - **WAIT for user confirmation:** "Is my understanding correct?"
4. **Create completion evidence:**
   - File: `phase-X.Y-completion-evidence.md`
   - List all success criteria as unchecked boxes
   - Document target files with line numbers
   - **If plan includes sub-phases (7B, 7C, 7D, etc.), list ALL sub-phases in completion criteria**
   - **ANY PLURAL must expand to separate checkboxes:** "Add innovations" must become:
     ```
     - [ ] Innovation 1: [specific name]
     - [ ] Innovation 2: [specific name]
     - [ ] Innovation 3: [specific name]
     ```
     NOT "✅ 3/3 innovations added" or "Add innovations (COMPLETE)". Each item gets its own checkbox. This prevents vague, game-able completion claims.
   - Create implementation checklist with token estimates
   - Add "⏸️ AWAITING STEP 1 APPROVAL" at end

   **Evidence file lifecycle:**
   - **Steps 1-4:** Temporary working document for tracking completion
   - **Step 5c:** Content appended to plan-log via safe concatenation, file deleted
   - **NOT committed to git** (plan-log contains the evidence after Step 5c)

5. **Request approval to proceed:**
   - Reference the evidence file created
   - **Ask explicitly:** "May I proceed with implementation?"

6. **Clarify full protocol commitment:**
   After asking "May I proceed?", explicitly state what this approval covers:

   ```
   Upon your approval, I will:
   1. Complete the implementation (Step 2)
   2. Create/update completion evidence (Step 3)
   3. Present deliverable to you and wait for your explicit approval (Step 4)
   4. ONLY AFTER approval: log to plan-log, git commit, update README (Step 5)
   ```

   **This clarifies that:**
   - "Proceed with implementation" means the full cycle through Step 4
   - Step 5 actions (logging/committing) only happen after user approval at the checkpoint
   - User will have opportunity to review work before it's logged/committed
   - This is a commitment to follow the protocol, not permission to skip ahead

7. **Wait for user response:**
   - User may approve → Proceed to Step 2
   - User may correct misunderstanding → Revise and re-present

7. **Create TodoWrite structure for protocol steps (REQUIRED):**

   TodoWrite makes protocol steps visible, trackable, and self-reinforcing. Create todos that mirror Steps 1-5.

   **Pattern:** Expand current phase into Steps 1-5, collapse completed/future phases to single lines. For simple phases, expand all 5 steps. For complex phases with sub-phases, defer Step 2 expansion: `{content: "Phase X Step 2: Complete sub-phases (will expand)", status: "pending", ...}` and collapse Steps 3-5.

   **Why:** User sees which protocol step you're on, can't skip steps without marking complete, Step 5 "setup Phase X+1" makes pattern self-reinforcing, cognitive load managed (8-12 total items).

8. **User may ask clarifying questions** → Answer and confirm

9. **Upon approval: Log plan to plan-log**
   - Use `plan-log` to document the approved plan
   - Include: phase number, deliverables, success criteria, approach
   - This creates session entry BEFORE implementation begins
   - Ensures plan is preserved even if implementation is interrupted
   - Then proceed to Step 2 (implementation)

---

**Example completion evidence (Step 1):**

```markdown
# Phase X.Y Completion Evidence

**Format source:** This completion evidence follows the template defined in `../guides/tandem-protocol.md` (Step 1: Plan Validation and Approval)

## Understanding of Plan
[Summary of what you'll do]

## Target Files Identified
- `/path/to/file1.md` (lines 50-75 will be modified)
- `/path/to/file2.md` (new file, estimated 200 lines)

## Success Criteria (Checklist)
- [ ] Feature X implemented
- [ ] Tests written for Feature X
- [ ] Documentation updated
- [ ] No conflicts with existing code

**For multi-phase tasks, list ALL sub-phases:**
- [ ] Phase 7B: Reframe Executive Summary
- [ ] Phase 7C: Reframe Sections 1-3
- [ ] Phase 7D: Reframe Sections 4-7
- [ ] Phase 7E: Add OTHER innovations
- [ ] Phase 7F: Verification pass

## Implementation Approach
Step 1: [action] (estimated 20K tokens, 15 min)
Step 2: [action] (estimated 30K tokens, 20 min)
...

## Token Budget
Total estimated: 75-100K tokens

## Questions for Validation
1. Is file path correct?
2. Should I also update related documentation?

# ⏸️ AWAITING STEP 1 APPROVAL
```

---

**Common mistakes:**

❌ **Skipping Step 0 entirely** - "I'll just start working and figure it out"
✅ **Always do Step 0** - Validates understanding, catches errors early

❌ **Vague target identification** - "I'll update the protocol file"
✅ **Precise targets** - "I'll insert 80 lines after line 552 in tandem-protocol.md"

❌ **No pre-implementation checklist** - Start work, discover gaps later
✅ **Checklist created first** - Know exactly what "done" looks like before starting

❌ **Assuming understanding is correct** - "The plan is clear, I don't need confirmation"
✅ **Explicit validation** - Present understanding, wait for confirmation

❌ **Implementation without approval** - Present validation but start work immediately
✅ **Wait for user "yes"** - Only proceed to Step 2 after explicit approval

---

**Real example: Wrong file targeted**

In a recent protocol update, initial plan stated:
```
Target: behavioral-review-plan-log.md lines 9-46
```

**Without Step 0:** Would have spent 65-90K tokens editing wrong file (plan log header instead of comprehensive guide).

**With Step 0:** Would have presented:
```
I understand the plan as: Update behavioral-review-plan-log.md protocol header
Target file: behavioral-review-plan-log.md (lines 9-46, currently 38 lines)
May I proceed?
```

User would have responded: "No, wrong file. Target is guides/tandem-protocol.md (563 lines)."

**Cost:** 5-10K tokens for Step 0 validation vs 65-90K tokens wasted on wrong implementation.

---

**When Step 1 is required:**
- Every phase start (always)
- After user provides new instructions
- When resuming work after conversation rewind
- When uncertain about any aspect of plan

**When Step 1 can be brief:**
- Very simple, single-action tasks (but still confirm targets)
- Continuation of clearly-specified work
- User has already validated targets in discussion

---

### Step 2: Complete the Deliverable(s) WITH Incremental Evidence Updates

**What:** Create the actual phase deliverable file(s) specified in the plan AND update completion evidence incrementally.

**Example:**
- Phase 0.1 deliverable: `phase-0-deep-research-notes.md`
- Phase 8.1 deliverable: `coaching-report-main.md`

**IMPORTANT: Maintain completion evidence as you work**
- For multi-part tasks, update the completion evidence document incrementally
- Check off completed items as you finish them (don't wait until the end)
- Document progress every 10-20 items or major milestones
- **Each item must have its own checkbox:** If adding 4 opportunities, create 4 separate checkboxes (one per opportunity), not "Add 4 opportunities (COMPLETE)"
- Check off each checkbox as you complete that specific item
- This creates audit trail and prevents claiming incomplete work as complete

**TodoWrite Integration for Multi-Phase Tasks (REQUIRED):**

**CRITICAL:** When Phase X has multiple sub-phases (X.1, X.2, X.3) or experiments (A, B, C, D), you MUST expand Step 2 into sub-phase todos with explicit BLOCKING evidence updates.

**At start of Step 2 for complex phase, expand TodoWrite:**
```javascript
TodoWrite({
  todos: [
    {content: "Phase 5 Step 1: Validate plan", status: "completed", activeForm: "Validating plan"},

    // Step 2 expanded into sub-phases with BLOCKING evidence updates
    {content: "Phase 5.1: Add Subagents column", status: "in_progress", activeForm: "Adding column"},
    {content: "Phase 5.1: Update evidence (BLOCKING)", status: "pending", activeForm: "Updating evidence"},
    {content: "Phase 5.2: Add flowchart", status: "pending", activeForm: "Creating flowchart"},
    {content: "Phase 5.2: Update evidence (BLOCKING)", status: "pending", activeForm: "Updating evidence"},
    {content: "Phase 5.3: Add comparison", status: "pending", activeForm: "Writing comparison"},
    {content: "Phase 5.3: Update evidence (BLOCKING)", status: "pending", activeForm: "Updating evidence"},
    {content: "Phase 5.4: Present sub-phase progress", status: "pending", activeForm: "Presenting progress"},

    // Steps 3-5 remain collapsed until Step 2 complete
    {content: "Phase 5 Steps 3-5: Evidence→present→approve→commit", status: "pending", "activeForm": "Finalizing Phase 5"},

    {content: "Phase 6: Cross-references", status: "pending", activeForm: "Updating references"},
  ]
})
```

**After completing each sub-phase (BLOCKING - MUST FOLLOW):**
1. Mark sub-phase work todo as completed (e.g., "Phase 5.1: Add Subagents column")
2. Update the completion evidence file (check off relevant boxes for that sub-phase)
3. Mark evidence update todo as completed (e.g., "Phase 5.1: Update evidence (BLOCKING)")
4. **Present to user:** "Completed Phase X.Y. Updated evidence: [N/M] checkboxes now complete."
5. **YOU CANNOT PROCEED to next sub-phase WITHOUT completing steps 1-4**

**Why BLOCKING:** Evidence updates are required checkpoints between sub-phases. Without incremental updates, protocol gets violated and audit trail is lost. User needs real-time progress visibility to course-correct early. The TodoWrite pattern is self-enforcing: next sub-phase is visible but can't proceed until evidence update is marked complete.

**How to verify completion:**
- Check plan for deliverable specifications
- Ensure file exists and contains required content
- Count lines/sections to verify scope
- Verify completion evidence document reflects actual progress

**Common mistakes:**
- Creating partial deliverable and calling it complete
- **CRITICAL: Not updating completion evidence during work** - Only updating at end loses audit trail (PROTOCOL VIOLATION)
- **CRITICAL: Working through all sub-phases then bulk-updating evidence** - Violates blocking requirement (lines 277-287)
- **CRITICAL: Not including evidence updates in TodoWrite** - Makes updates invisible and easy to forget (REQUIRED pattern)
- **CRITICAL: Not presenting evidence updates to user after each sub-phase** - User can't see incremental progress, violates step 4 blocking requirement
- **CRITICAL: Proceeding to next sub-phase without presenting progress** - Violates "YOU CANNOT PROCEED" requirement

---

### Step 3: Update Completion Evidence

**What:** After completing Step 2, update the completion evidence document from Step 1 with actual results.

**IMPORTANT:** The evidence document should end with `# ⏸️ AWAITING USER APPROVAL` at this stage. Do NOT mark it as "APPROVED" or "COMPLETE" yet - that happens in Step 5 AFTER user approval.

*(Evidence file lifecycle: See Step 1)*

**Update the completion evidence from Step 1:**
- Check off all completed items from the original checklist
- Add "Actual Results" section showing what was delivered
- Document any deviations from plan
- Add self-assessment with honest grade
- Keep the `# ⏸️ AWAITING USER APPROVAL` footer
- Do NOT change it to "APPROVED" until Step 5

**Required contents:**
1. **Header:**
   ```markdown
   # Phase X.Y Completion Evidence

   **Phase:** [Phase number and name]
   **Date Completed:** [YYYY-MM-DD]
   **Deliverable:** [filename] ([N] lines/pages)
   ```

2. **Completion Criteria Table:**
   - List ALL criteria from the plan
   - Provide verification evidence (line numbers, file sizes, specific examples)
   - Mark each criterion ✅ COMPLETE, ✅ PARTIAL, or ❌ INCOMPLETE

   Example:
   ```markdown
   | Criterion | Evidence | Status |
   |-----------|----------|--------|
   | Re-read FULL studies | Read complete source files for 4 studies | ✅ PARTIAL |
   | Ask WHY questions | Each study has "WHY Questions & Answers" sections | ✅ COMPLETE |
   | Document mechanisms | Lines 52-89, 244-301, 520-613, 753-841 | ✅ COMPLETE |
   ```

3. **Deliverable Details:**
   - File path
   - Size (lines/words)
   - Content structure summary
   - Key sections with line numbers

4. **Content Quality Verification:**

   **CRITICAL:** Verify actual deliverable quality, not just existence.

   **For all deliverables, check:**
   - **Size distribution:** Are all outputs reasonable size? (spot tiny/huge files)
   - **Spot-check samples:** Verify actual content from each section/category
   - **Error patterns:** Check for repeated errors or failure indicators
   - **Completeness:** Does content match expected structure/format?

   **Examples by task type:**

   *File downloads/generation:*
   - Check file size distribution: `find . -exec wc -l {} + | sort -n | head -20`
   - Spot-check first/last files in each section
   - Check for error pages (404, 500, etc.) in downloaded content
   - Verify expected vs actual file count per category

   *Code implementation:*
   - Run the code/tests to verify it executes
   - Check for compilation/runtime errors
   - Verify output matches expected behavior
   - Test edge cases and error conditions

   *Documentation/writing:*
   - Spot-read sections from beginning/middle/end
   - Check for placeholder text, TODOs, incomplete sections
   - Verify all promised sections exist
   - Check cross-references and links work

   *Batch operations:*
   - Sample items from each category/batch
   - Check for consistent quality across batches
   - Verify operation applied correctly to samples
   - Count completions vs total items

   **Red flags requiring investigation:**
   - All items same size (may indicate copy/paste or template errors)
   - Suspiciously small files (may be errors, not real content)
   - Missing sections/categories that were planned
   - Error messages or failure indicators in content
   - Count mismatches (expected N, got M)

5. **Deviations from Plan:**
   - Expected vs actual
   - Rationale for deviations
   - Impact assessment

6. **Key Insights Discovered:**
   - List major findings
   - Connect to evidence
   - Show understanding depth

7. **Self-Assessment:**
   - What went well
   - What could be better
   - Grade with justification (A-F, score/100)
   - Honest about shortcomings

7. **Footer:**
   ```markdown
   # ⏸️ AWAITING USER APPROVAL
   ```

**Special Case: Line-by-Line Edit Tasks**

For tasks involving systematic edits across many instances (e.g., reframing patterns, fixing citation errors, renaming variables):

**Step 1 MUST include:**
- **Complete numbered inventory** of ALL instances requiring edits in the completion evidence document
- Each instance with: line number, current text snippet, category (e.g., KEEP, REFRAME, CONSIDER), and recommended action
- Total count of instances
- Format with unchecked boxes: `- [ ]` for each item
- **THIS INVENTORY WITH CHECKBOXES STAYS IN THE COMPLETION EVIDENCE FILE AND GETS UPDATED IN STEP 3**

**File structure:**
- `phase-X-completion-evidence.md` contains BOTH the inventory (Step 1) AND the completion tracking (Step 3)

**Inventory format example:**
```markdown
## Inventory and Completion Tracking
**Total instances:** 116
**Method:** grep -n "pattern" file.md

### All Items
- [ ] 1. **Line 1:** "Title text" - KEEP (reason)
- [ ] 2. **Line 11:** "Generalization..." - REFRAME (lead with insight)
...
- [ ] 116. [final item]

**Categories:** KEEP: 30 (26%), REFRAME: 75 (65%), CONSIDER: 11 (9%)
```

**Step 2:** Work systematically through numbered checklist, update checkboxes every 10-20 edits, do NOT work opportunistically through grep searches.

*(See Step 2 for BLOCKING requirement details)*

**Step 3 (REQUIRED - BLOCKING):** Check boxes `- [ ]` → `- [x]`, add notes after each item.

**After Step 3:**
```markdown
- [x] 1. KEEP → KEPT (document title)
- [x] 2. REFRAME → COMPLETED: "Domain-optimal..."
- [ ] 3. REFRAME → NOT DONE
...
**Completion Summary:** Checked: 86/116 (74%), REFRAME: 45/75 (60%) ← INCOMPLETE
```

**Why required:** Prevents claiming incomplete work as complete, forces systematic work through inventory (not opportunistic editing), makes progress visible, enables spot-checking, creates audit trail. The inventory IS the work plan - must check off every item.

**Step 4 presentation (for line-by-line tasks):**
- **MUST include checklist completion percentage in presentation**
- Format: "Completed 116/116 items (100%)" or "Completed 86/116 items (74%) - INCOMPLETE"
- If <100%, explain what remains and why presenting early
- User can verify by checking the completion evidence file

**Common mistakes:**
- **CRITICAL: Making edits but not updating the checklist** - This leaves no evidence trail
- **Working through grep searches instead of the checklist** - Can't track which items were completed
- Vague evidence ("completed task" instead of "lines 52-89 show WHY analysis")
- **Summary metrics without line-by-line detail ("38 edits made" without listing which 38)**
- **Claiming high completion when edit count doesn't match inventory (38 edits vs 70 planned)**
- **Claiming 100% complete when checklist shows 0/116 checked** - The checklist IS the evidence
- Grade inflation (giving A when criteria not fully met)
- Grade reassessment (changing grade when initial grade isn't high enough)
- Hiding deviations from plan
- Forgetting the ⏸️ AWAITING USER APPROVAL marker

---

### Step 4: Present and Await Approval

**What:** Announce completion with structured summary, then wait for user review and explicit approval before proceeding to Step 5.

**BEFORE presenting, verify completion:**
1. **Check plan log for planned sub-phases** - If Phase X.1-X.5 were planned, verify ALL are complete
2. **Multi-phase tasks:** Cannot present "Phase X complete" if only X.1-X.3 are done and X.4-X.5 remain
3. **Options if incomplete:**
   - Complete remaining sub-phases first, THEN present
   - Present as partial: "Phase X.1-X.3 complete (X.4-X.5 deferred)"
   - Get user approval to skip remaining sub-phases

**Template:**
```
## Phase X.Y Complete

**Deliverable:** [filename] ([N] lines)
**Completion Evidence:** phase-X.Y-completion-evidence.md

### Key Highlights

1. [Major accomplishment with evidence]
2. [Critical insight discovered]
3. [Notable outcome or pattern]

**Upon your approval, I will:**
1. Update evidence file to mark Phase X.Y as APPROVED
2. Log Phase X.Y completion to plan-log.md
3. Update README with completion status
4. Git commit (deliverable + evidence + README + updated files)
5. Update TodoWrite (mark Phase X.Y complete, Phase X.Y+1 in_progress)
6. Proceed to Phase X.Y+1

**May I log and proceed?**
```

**Critical elements:**
- Concise (2-3 bullet highlights, not full summary)
- Evidence-based (cite line numbers, file sizes)
- **For line-by-line edit tasks:** MUST include checklist completion count (e.g., "116/116 items completed (100%)")
- **MUST list Step 5 actions before asking for approval** - User needs to know what "log and proceed" means
- **Explicit approval question:** "May I log and proceed?"
- **NO self-grade in presentation** (it's in evidence file; user will ask if they want to discuss)

**Common mistakes:**
- **CRITICAL: Presenting "Phase X complete" when sub-phases remain** - Check plan log first (e.g., completing 7B-D but not 7E-F)
- **CRITICAL: Using summary counts instead of separate checkboxes** - "✅ 4/4 innovations added" or "Add innovations (COMPLETE)" is vague. Must show each item with its own checkbox: "✅ Innovation 1: Multi-agent review", "✅ Innovation 2: Static analysis", etc.
- Long rambling summary (keep it to 3-5 sentences)
- Asking "Is this okay?" instead of explicit "May I log progress and proceed?"
- Forgetting to ask for approval
- **For line-by-line tasks: Not including checklist completion count** - This hides incomplete work
- **For line-by-line tasks: Saying "77 edits made" without checklist verification** - Could be 77/116 = incomplete
- Including self-grade in presentation (it's premature; user doesn't trust initial grades)
- Moving to next step without waiting for response

---

#### During User Review

**What:** After your presentation, user reviews your work. This is an active review process where user may request changes before approval.

**What WILL happen during review:**
- User reviews the completion evidence document
- User may ask: **"grade your work"** - Provide honest verbal assessment with specific deductions
- User may ask: **"improve your work"** - Make improvements and re-present
- User may provide their own feedback - Address it and re-present
- User may ask clarifying questions

**What you MUST do:**
1. **Wait for user action** - Don't proceed until user engages
2. **Respond to grading requests** - Honest assessment (this is when grade matters, not Step 4)
3. **Make improvements if requested** - Fix issues, update evidence file if needed, re-present
4. **Re-present after improvements** - Show what changed, reference updated evidence file, ask for approval again
5. **Wait for explicit approval** - Only proceed to Step 5 when user says "yes/approved/proceed" AFTER review is complete

**What you CANNOT do:**
- Log progress to plan log
- Commit changes to git
- Update README or status documents
- Start next phase
- Mark todo items as completed
- Assume silence = approval
- Skip the checkpoint by proceeding immediately after asking "May I log and proceed?"

**How to recognize approval:**
When user says "yes" to your "May I log progress and proceed?" question, that IS the checkpoint approval. Proceed immediately to Step 5.

User will say:
- "yes" or "approved" or "proceed"
- "okay, log it and continue"
- "go ahead with Step 5"

**Checkpoint variations:** User may approve directly, ask for grading first, or request improvements - see example below.

**Common mistakes:**
- **Waiting after "yes"** - When user says "yes", that completes the checkpoint. Don't wait for another signal.
- Assuming user feedback = final approval (they may have more feedback before saying "yes")
- Proceeding after timeout
- Not making requested improvements before re-presenting
- Forgetting to re-present after making improvements

**Example checkpoint sequence:**

```
Me: "Phase X.Y Complete"
Me: "Deliverable: file.md (500 lines)"
Me: "Completion Evidence: phase-X.Y-completion-evidence.md"
Me: "Key highlights: [1-3 items with evidence]"
Me: "May I log progress and proceed to Phase X.Y+1?"

[CHECKPOINT BEGINS - User reviews]

User: "grade your work"
Me: [provides honest verbal grade with specific deductions]
User: "improve your work"
Me: [makes improvements, updates evidence file if needed]
Me: "Improvements complete: [summary of changes]"
Me: "Updated evidence file reflects changes"
Me: "May I now log and proceed?"
User: "yes"

[CHECKPOINT ENDS - User has approved]

Me: [executes Step 5: README update, git commit, plan-log]
Me: [proceeds to next phase]
```

---

### Step 5: Post-Approval Actions

**What:** After explicit user approval (Step 4), perform ALL of these actions IN ORDER:

#### 5a. Update Completion Evidence to "APPROVED"

**First action after approval:** Update the evidence document to show approval received.

If using pre-implementation evidence:
```markdown
# ✅ APPROVED BY USER - [Date]

User approved on [date] with comment: "[user's approval message]"

**Final Results:**
[Same content that was under "Actual Results"]
```

If using separate completion evidence:
- Change footer from `# ⏸️ AWAITING USER APPROVAL` to `# ✅ APPROVED`
- Add approval date and user comment if relevant

**Why this is 5a:** Evidence document must reflect approval before being committed.

#### 5b. Update README
- Update project README (`coaching-report/README.md` or similar)
- Mark phase as completed
- Add deliverable to deliverables list
- Update "Last Modified" date

Example:
```markdown
## Phase 0.1: Deep Research Re-engagement ✅

**Status:** Complete (2025-01-18)
**Deliverable:** `phase-0-deep-research-notes.md` (966 lines)
**Evidence:** `phase-0.1-completion-evidence.md`
```

#### 5c. Log to Plan Log
- Add entry to plan-log BEFORE committing
- Must include: "User approved Phase X.Y on [date]"
- **Append full completion evidence to plan-log entry**
- Use `bash -c` with brace group for safe concatenation:

```bash
bash -c '{
  cat <<'\''EOF'\''
# Phase X.Y Complete: [Title]

User approved Phase X.Y on [date].

## Progress

**Deliverable:** [filename] ([N] lines)
**Key accomplishments:**
- [Item 1 with evidence]
- [Item 2 with evidence]

## Evidence

EOF
  cat phase-X.Y-completion-evidence.md
  cat <<'\''EOF'\''

## Plan

Phase X.Y+1: [Next phase tasks]
EOF
} | plan-log'

# After successful append, delete temporary evidence file
rm phase-X.Y-completion-evidence.md
```

**Why safe:** bash -c wrapper required for Claude Code piping, quoted heredoc prevents command substitution, cat streams verbatim. Security guarantee: evidence content with $(...) or backticks treated as literal text (no execution risk).

**Alternative approach:** Build complete entry in /tmp/plan-entry.md, then pipe to plan-log.

**Why log before commit:** So the plan log entry (with appended evidence) gets committed along with everything else.

#### 5d. Git Commit
- Commit deliverable + README + plan log entry
- Evidence file was already appended to plan-log in Step 5c and deleted (not committed separately)
- Use descriptive commit message
- Follow format:

```bash
git add coaching-report/phase-0-deep-research-notes.md
git add coaching-report/README.md
git commit -m "Phase 0.1 complete: Deep research re-engagement with WHY questions

Analyzed 4 core studies (#106, #179, #159, #192) with mechanism-level understanding.
Key insight: User's 0.9% agent usage is correct for experienced developers, not a gap.

966 lines of analysis documenting causal chains and cross-study patterns.
Self-grade: A- (91/100)

Evidence appended to plan-log (not committed as separate file).

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Note:** Plan log was already updated by `plan-log` command in 5c (with evidence appended), so it gets committed automatically here. Evidence file was deleted after append.

#### 5e. Update TodoWrite and Start Next Phase (Self-Reinforcing Pattern)

**CRITICAL:** This is where the self-reinforcing pattern activates. You must create the protocol structure for Phase X+1.

**Actions:**
1. **Collapse completed phase** - Mark all Phase X steps as completed, collapse to single line
2. **Create Phase X+1 protocol structure** - Expand Steps 1-5 for next phase
3. **Keep future phases collapsed** - Phase X+2, X+3 remain as single lines

**For simple next phase:**
```javascript
TodoWrite({
  todos: [
    // Completed phases (collapsed)
    {content: "Phase 3: Context injection", status: "completed", activeForm: "Adding context patterns"},
    {content: "Phase 4: Main SKILL.md updates", status: "completed", activeForm: "Updating SKILL.md"},

    // Next phase (expanded into Steps 1-5) - THIS IS THE SELF-REINFORCING PART
    {content: "Phase 5 Step 1: Validate plan", status: "in_progress", activeForm: "Validating plan"},
    {content: "Phase 5 Step 2: Complete deliverable", status: "pending", activeForm: "Creating deliverable"},
    {content: "Phase 5 Step 3: Update evidence", status: "pending", activeForm: "Documenting completion"},
    {content: "Phase 5 Step 4: Present and await approval", status: "pending", activeForm: "Presenting and awaiting approval"},
    {content: "Phase 5 Step 5: Post-approval (evidence→plan-log heredoc→commit→setup Phase 6)", status: "pending", activeForm: "Finalizing Phase 5"},

    // Future phases (collapsed)
    {content: "Phase 6: Cross-references", status: "pending", activeForm: "Updating references"},
    {content: "Phase 7: Real-world examples", status: "pending", activeForm: "Integrating examples"},
  ]
})
```

**For complex next phase (defer sub-phase expansion until Step 2):**
```javascript
{content: "Phase 5 Step 1: Validate plan", status: "in_progress", activeForm: "Validating plan"},
{content: "Phase 5 Step 2: Complete sub-phases (will expand)", status: "pending", activeForm: "Working on deliverables"},
{content: "Phase 5 Steps 3-5: Evidence→present→approve→commit", status: "pending", "activeForm": "Finalizing Phase 5"},
```

**After updating TodoWrite, begin next phase (absorbing old Step 7):**
- Read the plan for Phase X+1
- Understand success criteria
- Start with Step 1 validation for new phase
- Do NOT skip Step 1, even if returning from Step 0 checkpoint

**Why self-reinforcing:** Step 5e explicitly says "setup Phase X+1", which requires creating Steps 1-5 for next phase. Pattern continues automatically.

**Common mistakes when starting next phase:**
- Starting next phase before Step 5
- Forgetting what the next phase actually requires
- Not checking plan before starting
- Skipping Step 1 validation for new phase

**Order matters:** README → Git → Log → TodoWrite

**Common mistakes:**
- Skipping any of these steps
- Doing them out of order
- Logging before user approval
- Vague log entries without "User approved" statement

---

## Quick Reference Checklist

When completing a phase, verify:

**Process Management:**
- [ ] Context window monitored (stayed under 140K token threshold)
- [ ] TodoWrite updated every 40-50K tokens during work
- [ ] Checkpoint executed via plan-progress if token budget exceeded

**Protocol Steps:**
- [ ] Step 0: Cleaned up old evidence files from previous session (if starting new planning session)
- [ ] Step 1: Created pre-implementation evidence (temporary working doc), validated plan understanding, got approval to proceed
- [ ] Step 2: Deliverable file exists and meets plan specifications
- [ ] Step 2: **BLOCKING: For multi-phase tasks - TodoWrite included evidence update todos after each sub-phase (REQUIRED)**
- [ ] Step 2: **BLOCKING: For multi-phase tasks - Evidence checkboxes updated incrementally AND presented to user after EACH sub-phase (YOU CANNOT PROCEED without this)**
- [ ] Step 3: `phase-X.Y-completion-evidence.md` created with all required sections (temporary file for Steps 1-4)
- [ ] Step 3: Content quality verified (size distribution, spot-checks, error patterns checked)
- [ ] Step 3: Evidence document ends with `# ⏸️ AWAITING USER APPROVAL`
- [ ] Step 4: Presented to user with structured summary and explicit approval question, then waited for explicit user approval
- [ ] Step 5a: Updated completion evidence to "APPROVED" status
- [ ] Step 5b: Updated README with completion status
- [ ] Step 5c: Appended evidence to plan-log via bash -c, deleted temp evidence file
- [ ] Step 5d: Git committed (deliverable + README)
- [ ] Step 5e: Updated TodoWrite and started next phase (with Step 1 validation, including Step 0 if new session)

**If any checkbox is unchecked, the protocol is not complete.**

---

## Examples

### Good Example: Step 1 Plan Validation

```markdown
## Step 1: Plan Validation for Protocol Update

**I understand the plan as:** Add Step 1 (Plan Validation) to Tandem Protocol guide

**Target files identified:**
- `/home/ted/projects/urma-next-obsidian/guides/tandem-protocol.md` (924 lines)
- Will insert Step 1 section before current Step 2 (line 149)
- Will renumber existing steps 1-6 → 2-7
- Will update Quick Reference Checklist (lines 493-513)
- Will add Step 1 example to Examples section

**Success criteria:**
- [ ] Step 1 section added (80-100 lines estimated)
- [ ] All existing steps renumbered 2-7
- [ ] Quick Reference updated with Step 1
- [ ] Example showing Step 1 validation added
- [ ] Tone matches existing guide format

**Implementation approach:**
- Step 1: Draft Step 1 section (30-40K tokens, 30 min)
- Step 2: Renumber all steps and cross-references (15-20K tokens, 20 min)
- Step 3: Update Quick Reference (5-10K tokens, 10 min)
- Step 4: Add example (10-15K tokens, 15 min)
- Step 5: Update pre-impl evidence (5K tokens, 10 min)

**Token budget:** 65-90K tokens, 85 minutes

**Pre-implementation evidence:** `step-1-addition-pre-implementation.md` created with full checklist

**May I proceed with implementation?**

*(Upon approval, list Step 5 actions as shown in Step 4 template)*
```

✅ **What's good:**
- Precise target identification (file path, line numbers)
- Complete success criteria as checkboxes
- Token budget and timeline estimated
- Protocol commitment clearly stated (what happens after approval)
- Pre-implementation evidence document created
- Clear approval question

**User response:** "1: renumber. 2: yes. 3: that's fine" → Approval granted, clarified numbering approach

### Good Example: Phase 0.1 Completion

```markdown
## Phase 0.1 Complete

**Deliverable:** phase-0-deep-research-notes.md (966 lines)
**Completion Evidence:** phase-0.1-completion-evidence.md

### Key Highlights

1. Analyzed 4 core studies (N=5,080 participants) with mechanism-level WHY analysis
2. Critical insight: User's 0.9% agent usage is CORRECT for experienced developers (Source #192)
3. Cross-study synthesis begun: bounded vs unbounded task architecture identified

### Self-Grade: A- (91/100)

**Deductions:** -5 for 50% study coverage, -4 for citation error discovered

**May I log progress and proceed to Phase 0.2?**
```

✅ **What's good:**
- Concise highlights with evidence
- Honest grading with deductions
- Explicit approval question

### Bad Example

❌ **Common presentation mistakes:**
- No evidence (line numbers, file names, sizes)
- No completion evidence document
- No self-grade
- Vague summaries ("read some studies", "found some patterns")
- Casual tone
- Weak approval question
- Missing ⏸️ marker

### Good Example: Context Window Checkpoint

✅ **Checkpoint execution at 138K tokens (69%):** Recognized threshold approaching 140K, stopped immediately, used plan-progress to document completed work (research gathering) vs incomplete work (draft not started), estimated remaining tokens needed (60-80K), and provided clear handoff to next session with specific priorities and checkpoint strategy.

---

## Common Failure Modes

| Mode | Symptom | Why | Prevention |
|------|---------|-----|------------|
| Silent Advancement | AI logs/starts without approval | Eagerness, assumes completion=approval | Wait for explicit "yes, approved, proceed" |
| Fake Completion | Marks phase complete when criteria not met | Avoid appearing stuck, scope fatigue | Honest self-grading, explicit deviations |
| Evidence-Free Claims | Says "completed" without line numbers/proof | Treats evidence as formality | Specific evidence (lines, file sizes, quotes) |
| Protocol Shortcuts | Skips steps (no commit, README, log) | Sees steps as bureaucratic overhead | Understand WHY each step exists |
| Assumed Approval | User says "good work", AI proceeds | Interprets positive feedback as approval | Ask explicitly: "Does this include logging/proceeding?" |

---

## Debugging Protocol Failures

If you realize you violated the protocol:

1. **Stop immediately** - Don't compound the error
2. **Acknowledge the violation** - "I realize I proceeded without approval. This violated the protocol."
3. **Assess damage:**
   - Did I log without approval? (Undo: remove log entry)
   - Did I commit without approval? (Undo: git reset)
   - Did I start next phase? (Undo: return to approval wait)
4. **Present correctly** - Follow Step 3 properly
5. **Wait for approval** - Follow Step 4 this time
6. **Learn from it** - Why did I skip the protocol? What assumption was wrong?

**Don't:**
- Hide the violation
- Continue forward hoping user won't notice
- Make excuses ("I thought you meant...")
- Argue the protocol is unnecessary

---

## Protocol Variations

**Sub-Phases:** Same protocol applies, each sub-phase gets its own evidence document, log each completion separately, user approval required for each. **Quick Fixes/Corrections:** During Step 4, make correction, update evidence if needed, re-present with "Addressed feedback: [description]", wait for approval again. **Multi-Deliverable Phases:** Create one evidence document covering all deliverables, list each separately with individual verification, present as bundle with combined grade.

---

## Integration with Other Tools

**plan-show:** Run at session start to see protocol + current plan (restores context after compaction). **plan-search:** Find previous phase completions, search "User approved Phase" for approval patterns. **git:** Reference phase number and grade in commits, include 🤖 Claude Code footer, use conventional format.

### With TodoWrite: Incremental Algorithm

**Purpose:** TodoWrite tracks progress but can become overwhelming (>15 items = cognitive overload). Use incremental expansion to maintain focus while providing clear phase transitions.

---

#### Algorithm: Expand Current, Collapse Others

**Initial setup (7-8 phase overview):** Start with collapsed view showing all phases as single lines.

**During work (expand current phase):** Expand active phase into 5-7 sub-tasks. Pattern: completed phases collapsed, current phase expanded (with "Load Phase X+1 todos" as last sub-task), future phases collapsed. Total: 8-12 visible items.

**Planned sub-phases:** If plan specifies Phase 7A-7F, treat each as separate todo (prevents presenting "Phase 7 complete" when 7E-7F remain).

**Update frequency:** Every 40-50K tokens, after each sub-task, when starting new phase, at checkpoint boundaries (120K, 140K). Maintains progress awareness and triggers checkpoint assessment.

**Phase transition (after Step 5 approval):** Collapse completed phase to one line, expand next phase into sub-tasks, mark first sub-task "in_progress".

---

#### Common Mistakes

| Don't | Do |
|-------|-----|
| Expand all phases at once (30+ items, overwhelming) | One phase expanded at a time (8-12 items) |
| Not update during phase (todos become stale) | Update every 40-50K tokens (shows velocity) |
| Forget "Load Phase X+1" task (unclear when to expand) | Always include transition task (clear signal) |
| Keep completed sub-tasks visible (list grows unbounded) | Collapse completed phases (focus on current/future) |

---

#### Integration with Tandem Protocol

Update at: Step 1 (update sub-tasks as completed), Step 5d (collapse current, expand next), between sessions (persists to show resume point).

---

**Why this algorithm:** Incremental expansion prevents cognitive overload (8+ phases = 40+ items). Maintains 8-12 visible items for focus while showing project arc. Updating every 40-50K tokens tracks progress and token budget.

---

## For AI Agents: Mental Model

Treat protocol as contract/quality gates/audit trail (not bureaucratic overhead or optional formality). Required because AI drifts during long sessions, compaction erases context, users need approval checkpoints, and explicit authorization is needed for git commits.

---

## Context Window Management for Long Sessions

**Why this matters:** Multi-phase projects can consume 100K+ tokens in a single session. Without checkpoint discipline, you may exhaust context before completing deliverables, requiring conversation rewind and lost work.

**Learned from:** Actual failure mode where 139K/200K tokens (70%) were spent on research gathering without completing the revision deliverable.

---

### Before Starting Any Phase

**Estimate token budget by task type:**

| Task Type | Typical Token Usage |
|-----------|-------------------|
| Research (reading sources) | 30-50K per source |
| Drafting (writing new content) | 20-30K per deliverable |
| Revision (editing existing) | 10-20K per file |
| Verification (testing, checking) | 5-15K per check |
| Agent queries (Task/Explore) | 5-10K per query |

**Strategy:** Use Task agents for targeted queries (5-10K tokens) instead of reading full files (30-50K tokens) - agents return targeted information without loading full file content.

---

### During Work: Checkpoint Triggers

**Context window budget: 200K tokens (typical)**

**Checkpoint thresholds:**

1. **120K tokens (60% usage) - Assessment checkpoint:**
   - Stop and assess: "Can I complete deliverable with 80K remaining?"
   - Questions to ask:
     - Is deliverable 80%+ complete?
     - Do I need more research (high token cost)?
     - Are there unexpected complications?
   - **If NO to first question:** Execute checkpoint now
   - **If YES:** Continue but monitor closely

2. **140K tokens (70% usage) - FORCE checkpoint:**
   - **Stop immediately** regardless of progress
   - Document current progress
   - Execute checkpoint via `plan-progress`
   - Get user approval before continuing
   - **Why force:** 60K remaining insufficient for completion + potential revisions

**How to check current usage:**
- Look for `<system_warning>Token usage: XXXXX/200000` in responses
- Track major operations (Read calls, agent queries, large edits)
- Update TodoWrite with token awareness

---

### Executing a Checkpoint

**Use the `plan-progress` command:**

```bash
plan-progress <<'EOF'
# Progress: [Phase name] - CHECKPOINT (Token Budget)

## Progress

**Completed:**
- [List completed sub-tasks with evidence]
- [File names, line counts, specific accomplishments]

**Token usage:** XXXk/200K (XX%)
**Deliverable status:** [XX% complete | incomplete]

**Self-grade for work completed:** [Grade] ([score]/100)

## Plan

**Next session first priority:** [What to do immediately]

**Remaining work:**
1. [Specific task with token estimate]
2. [Specific task with token estimate]

**Estimated tokens needed:** XX-XXk
EOF
```

---

### Common Mistakes

❌ **"I'll just finish this one more thing"** - Often leads to 10-20K more tokens and incomplete work
✅ **Checkpoint at threshold** - Clean break preserves progress

❌ **Reading full files for research** - Burns 30-50K per file
✅ **Use Task agents with queries** - 5-10K per request

❌ **No token tracking** - Sudden surprise at 180K usage
✅ **Update TodoWrite every 40-50K** - Maintains awareness

❌ **Combining research + execution** - Unpredictable budget
✅ **Separate phases** - Research phase, then execution phase

---

### Integration with TodoWrite

Add checkpoint awareness to todos:

```javascript
TodoWrite({
  todos: [
    {content: "CHECKPOINT AT 120K tokens", status: "pending"},
    {content: "Phase 2: Draft additions", status: "in_progress"},
    // ... rest
  ]
})
```

Update every 40-50K tokens to maintain threshold awareness.

---

## Appendix: Verification Templates

This appendix provides copy-paste templates for Step 3 content quality verification.

**Note:** Verification results should be documented in the completion evidence file (Step 3). The evidence file is then appended to plan-log in Step 5c, making verification checklists part of the permanent audit trail.

### Template 1: File Download/Generation Verification

```bash
# Check file count by category
find output_dir -type f -name "*.ext" | wc -l

# Check size distribution (spot outliers)
find output_dir -type f -name "*.ext" -exec wc -l {} + | sort -n | head -20
find output_dir -type f -name "*.ext" -exec wc -l {} + | sort -n | tail -20

# Check for error pages (common patterns)
grep -r "404" output_dir/
grep -r "Not Found" output_dir/
grep -r "Error" output_dir/ | head -20

# Spot-check first file in each section
ls output_dir/section1/ | head -1 | xargs -I {} head -30 "output_dir/section1/{}"
ls output_dir/section2/ | head -1 | xargs -I {} head -30 "output_dir/section2/{}"

# Verify no empty files
find output_dir -type f -size 0

# Count by subdirectory
for dir in output_dir/*/; do echo "$(basename $dir): $(find $dir -type f | wc -l)"; done
```

**Checklist:**
- [ ] Total file count matches expected
- [ ] No files with suspicious sizes (too small/large)
- [ ] No error patterns in content
- [ ] Spot-checks show valid content
- [ ] All categories/sections present

### Template 2: Code Implementation Verification

```bash
# Compile/build check
npm run build
# OR
cargo build
# OR
python -m py_compile *.py

# Run tests
npm test
# OR
cargo test
# OR
pytest

# Check for compilation warnings
npm run build 2>&1 | grep -i "warning"

# Run specific edge case tests
npm test -- --grep "edge case"

# Check code executes without errors
node script.js
# OR
python script.py

# Verify output matches expected
node script.js > output.txt
diff output.txt expected_output.txt
```

**Checklist:**
- [ ] Code compiles/builds without errors
- [ ] All tests pass
- [ ] No critical warnings
- [ ] Edge cases handled correctly
- [ ] Output matches expected behavior

### Template 3: Documentation/Writing Verification

```bash
# Check document structure
grep "^#" document.md  # All headings
grep "^## " document.md | wc -l  # Count main sections

# Check for placeholder text
grep -i "TODO" document.md
grep -i "TBD" document.md
grep -i "FIXME" document.md
grep "\[.*\]" document.md  # Bracket placeholders

# Check for incomplete sections
grep -A 5 "^## " document.md | grep -B 1 "^$"  # Empty sections

# Word count per section
awk '/^## / {if (NR>1) print section, words; section=$0; words=0; next} {words+=NF} END {print section, words}' document.md

# Check cross-references exist
grep -o "\[.*\](.*.md)" document.md | cut -d'(' -f2 | cut -d')' -f1 | while read file; do
  [ -f "$file" ] && echo "✓ $file" || echo "✗ Missing: $file"
done

# Spot-read sections
head -50 document.md  # Beginning
awk 'NR==100,NR==150' document.md  # Middle
tail -50 document.md  # End
```

**Checklist:**
- [ ] All promised sections exist
- [ ] No TODO/TBD/FIXME placeholders
- [ ] No empty sections
- [ ] Word counts reasonable per section
- [ ] Cross-references valid
- [ ] Spot-checks show quality content

### Template 4: Batch Operations Verification

```bash
# Sample items from each category
find category1/ -type f | shuf -n 3  # 3 random files
find category2/ -type f | shuf -n 3

# Check operation applied correctly
for file in $(find output/ -type f | shuf -n 5); do
  echo "=== $file ==="
  # Check specific operation result
  grep "expected_pattern" "$file" && echo "✓" || echo "✗ MISSING"
done

# Verify consistency
find output/ -type f -exec grep -l "operation_marker" {} \; | wc -l  # Should match total

# Count completions vs total
total=$(find input/ -type f | wc -l)
completed=$(find output/ -type f | wc -l)
echo "Completed: $completed / $total"

# Check for failures
[ -f failed_items.txt ] && wc -l failed_items.txt || echo "No failures recorded"

# Verify no partial/corrupted output
find output/ -type f -exec file {} \; | grep -v "expected_type"
```

**Checklist:**
- [ ] Sampled items show correct operation
- [ ] All categories processed
- [ ] Operation consistent across batches
- [ ] Completion count correct
- [ ] Failures logged if any

### Template 5: Test Suite Verification

```bash
# Run tests with coverage
npm test -- --coverage
# OR
pytest --cov=src tests/

# Check test count
grep -r "^test(" tests/ | wc -l  # Count test functions
grep -r "it(" tests/ | wc -l  # Count Jest/Mocha tests

# Verify all features tested
echo "Features implemented:"
grep -r "function " src/ | cut -d' ' -f2 | cut -d'(' -f1 | sort -u
echo "Features tested:"
grep -r "test.*function_name" tests/ | wc -l

# Run tests and check exit code
npm test
echo "Exit code: $?"  # Should be 0

# Check for skipped tests
grep -r "skip" tests/
grep -r "xit(" tests/
grep -r "xdescribe(" tests/

# Timing check (performance regression)
npm test 2>&1 | grep "Time:"
```

**Checklist:**
- [ ] All tests pass
- [ ] Coverage meets threshold (e.g., >80%)
- [ ] All features have tests
- [ ] No skipped tests without reason
- [ ] Test execution time reasonable

