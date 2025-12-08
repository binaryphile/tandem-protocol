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

**Step 1:** Plan validation + approval
- Present plan understanding
- **⛔ BLOCKING: Ask clarifying questions** (assumptions, alternatives, edge cases)
- Get explicit user approval ("proceed")
- Create deliverable contract
- Create TodoWrite structure

**Step 2:** Implementation
- Execute the actual work
- Mark todos in_progress → completed

**Step 3:** Checkpoint preparation
- Update contract with completion
- Add "⏸️ AWAITING USER APPROVAL" footer

**Step 4:** Present and WAIT
- Present deliverables to user
- List Step 5 actions
- **CRITICAL: Do NOT proceed without explicit approval**

**Step 5:** Post-approval (after "yes"/"approved"/"proceed")
- Update contract to APPROVED
- Commit contract file to git
- Update TodoWrite

## Check Your Current Step

**Where are we right now?**

1. Check the contract file for current status
2. Check TodoWrite for which step is "in_progress"
3. If at Step 4 boundary, have you gotten explicit approval?

## Common Mistakes to Avoid

- **Skipping Step 1:** Never implement before plan approval
- **Forgetting clarifying questions:** Step 1 requires asking about ambiguities before proceeding
- **Forgetting Step 3:** Always update contract before presenting
- **Step 4→5 violations:** Never proceed to logging/committing without "yes"/"approved"/"proceed"
- **Feedback = Plan Change:** User feedback that changes scope/approach → return to Step 1
- **TodoWrite sync:** Keep TodoWrite updated in real-time
- **Mental model drift:** Don't assume you know the protocol - read the actual text
