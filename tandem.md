---
description: "Tandem Protocol reminder - check current step and ensure compliance"
---

<system-reminder>
After reading this, check your current step in the Tandem Protocol and ensure compliance with the 5-step workflow.
</system-reminder>

# Tandem Protocol Reminder

## Protocol Location

The Tandem Protocol is loaded in context via CLAUDE.md:

```
# Full version (with background & examples):
@~/tandem-protocol/tandem-protocol.md

# OR Concise version (mechanics only):
@~/tandem-protocol/tandem-protocol-concise.md
```

**You already have the protocol in context.** Do NOT re-read tandem-protocol-concise.md or tandem-protocol.md - use what's in your context window. This command is just a memory jogger.

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
