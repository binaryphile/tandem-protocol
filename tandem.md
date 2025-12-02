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

**You already have the protocol in context.** This command is just a memory jogger.

## Quick 5-Step Reference

**Step 0:** Evidence cleanup (only for NEW planning sessions)

**Step 1:** Plan validation + approval
- Present plan understanding
- Get explicit user approval ("proceed")
- Create evidence file
- Create TodoWrite structure

**Step 2:** Implementation
- Execute the actual work
- Mark todos in_progress → completed

**Step 3:** Checkpoint preparation
- Update evidence with completion
- Add "⏸️ AWAITING USER APPROVAL" footer

**Step 4:** Present and WAIT
- Present deliverables to user
- List Step 5 actions
- **CRITICAL: Do NOT proceed without explicit approval**

**Step 5:** Post-approval (after "yes"/"approved"/"proceed")
- Update evidence to APPROVED
- Commit evidence file to git
- Update TodoWrite

## Check Your Current Step

**Where are we right now?**

1. Check the evidence file for current status
2. Check TodoWrite for which step is "in_progress"
3. If at Step 4 boundary, have you gotten explicit approval?

## Common Mistakes to Avoid

- **Skipping Step 1:** Never implement before plan approval
- **Forgetting Step 3:** Always update evidence before presenting
- **Step 4→5 violations:** Never proceed to logging/committing without "yes"/"approved"/"proceed"
- **TodoWrite sync:** Keep TodoWrite updated in real-time
