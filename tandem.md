---
description: "Tandem Protocol reminder - check current step and ensure compliance"
---

<system-reminder>
Your mental model of the Tandem Protocol may not match the actual spec. Refresh your understanding by finding and reading the relevant step from the protocol text already in your context.

**REQUIRED:** Before taking any action, find the relevant step section in your context (from ~/projects/share/tandem-protocol/tandem-protocol-concise.md) and quote it. Do NOT use the Read tool - the file is already loaded.
</system-reminder>

# Tandem Protocol Reminder

## Refresh Your Mental Model

You have a mental model of the protocol, but if you're seeing this reminder, the model isn't being followed correctly. **Find and read the actual protocol text in your context window.**

**Protocol file:** `~/projects/share/tandem-protocol/tandem-protocol-concise.md` (already in context - do NOT re-read with Read tool)

**Before proceeding:** Find the section for your current step in context and quote it in your response. This ensures you're working from the spec, not from memory.

## Quick 5-Step Reference

**Step 0:** Contract cleanup (only for NEW planning sessions)

**Step 1:** Plan validation + approval (4 sub-steps)
- **1a:** Present plan understanding
- **1b:** ⛔ BLOCKING: Ask clarifying questions (wait for answers)
- **1c:** Create contract file (with Step 1 checklist)
- **1d:** Request approval (wait for "proceed")

**Step 2:** Implementation
- Execute the actual work
- Mark todos in_progress → completed

**Step 3:** Update contract
- Mark success criteria complete
- Add actual results, self-assessment
- Add Step 4 Checklist

**Step 4:** Present + await approval (2 sub-steps)
- **4a:** Present results (mark checklist)
- **4b:** ⛔ BLOCKING: Await approval (wait for "proceed")

**Step 5:** Post-approval (4 sub-steps)
- **5a:** Mark approved in contract
- **5b:** Commit deliverable to git
- **5c:** Log contract to plan-log (if available), then delete
- **5d:** Setup next phase

## Check Your Current Step

**Where are we right now?**

1. Check the contract file for current status
2. Check TodoWrite for which step is "in_progress"
3. If at Step 4 boundary, have you gotten explicit approval?

## Common Mistakes to Avoid

- **Skipping sub-steps:** Step 1 has 4 sub-steps, Step 4 has 2 sub-steps. Execute each fully.
- **Skipping 1b:** MUST ask clarifying questions and wait for answers before creating contract
- **Creating contract early:** Contract (1c) comes AFTER questions answered, not before
- **Forgetting Step 3:** Always update contract + add Step 4 Checklist before presenting
- **Step 4→5 violations:** Never proceed to commit without "yes"/"approved"/"proceed"
- **Feedback = Plan Change:** User feedback that changes scope/approach → return to Step 1
- **TodoWrite sync:** Keep TodoWrite updated in real-time
- **Mental model drift:** Don't assume you know the protocol - quote the actual sub-step text
