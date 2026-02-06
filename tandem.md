---
description: "Tandem Protocol reminder - check current step and ensure compliance"
---

<system-reminder>
**REQUIRED:** Before taking any action, find the relevant step section in your context (from ~/projects/share/tandem-protocol/tandem-protocol.md) and quote it. Do NOT use the Read tool - the file is already loaded.
</system-reminder>

# Tandem Protocol Reminder

## Refresh Your Mental Model

You have a mental model of the protocol, but if you're seeing this reminder, the model isn't being followed correctly. **Find and read the actual protocol text in your context window.**

**Protocol file:** `tandem-protocol.md` (already in context - do NOT re-read with Read tool)

**Before proceeding:** Find the section for your current step in context and quote it in your response. This ensures you're working from the spec, not from memory.

## Check Your Current Step

**Where are we right now?**

1. Check the contract file for current status
2. Check Tasks API for which step is "in_progress"
3. If at Step 4 boundary, have you gotten explicit approval?

## Common Mistakes to Avoid

- **Skipping sub-steps:** Steps may have sub-steps. Execute each fully.
- **Skipping 1b:** MUST ask clarifying questions and wait for answers before creating contract
- **Creating contract early:** Contract (1c) comes AFTER questions answered, not before
- **Forgetting Step 3:** Always update contract + add Step 4 Checklist before presenting
- **Step 4→5 violations:** Never proceed to commit without "yes"/"approved"/"proceed"
- **Feedback = Plan Change:** User feedback that changes scope/approach → return to Step 1
- **Tasks API drift:** Keep Tasks API updated in real-time
- **Mental model drift:** Don't assume you know the protocol - quote the actual sub-step text

## Step 5b/5c Reminder

**5b: Archive** (before commit so history is included):
```bash
echo -e "\n---\n## Archived: $(date -I)\n" >> plan-history.md
cat phase-N-contract.md >> plan-history.md
rm phase-N-contract.md
```

**5c: Commit** deliverable AND plan-history.md together.
