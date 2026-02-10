---
description: "Tandem Protocol reminder - check current step and ensure compliance"
---

<system-reminder>
**REQUIRED:** Before taking any action, find the relevant section in your context (from ~/tandem-protocol/README.md) and quote it. Do NOT use the Read tool - the file is already loaded.
</system-reminder>

<system-reminder>
**TaskAPI at Gates - INVOKE these tools:**
- Gate 1: TaskCreate for each task, TaskUpdate first to in_progress
- Gate 2: TaskUpdate completed, then TaskUpdate deleted for each
</system-reminder>

# Tandem Protocol Reminder

## Refresh Your Mental Model

You have a mental model of the protocol, but if you're seeing this reminder, the model isn't being followed correctly. **Find and read the actual protocol text in your context window.**

**Protocol file:** `README.md` (already in context - do NOT re-read with Read tool)

**Before proceeding:** Find the section for your current stage in context and quote it in your response. This ensures you're working from the spec, not from memory.

## Check Your Current Stage

**Where are we right now?**

1. Check plan-log.md for current status
2. Check Tasks API for which task is "in_progress"
3. Have you gotten explicit approval at the gate?

## PI Model

| Stage | What Happens | Gate |
|-------|--------------|------|
| **Plan** | Explore, understand, ask questions, design | Gate 1: approve plan |
| **Implement** | Execute, present results | Gate 2: approve results |

## Plan Mode Entry - EXECUTE NOW

If an existing plan file exists, execute this bash block to quote it verbatim:

```bash
# Force verbatim plan quote (Tier 1 - executable)
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
if [[ -f "$PLAN_FILE" ]]; then
    echo "=== EXISTING PLAN (verbatim) ==="
    cat "$PLAN_FILE"
    echo "=== END PLAN ==="
    echo ""
    echo "Now grade your understanding, then grade the plan quality."
    echo "Wait for user approval before proceeding."
fi
```

After executing, present your grades and ask: "May I proceed?"

## Common Mistakes to Avoid

- **Skipping questions:** Ask clarifying questions before Gate 1, not after
- **Proceeding without approval:** Never pass a gate without "yes"/"approved"/"proceed"
- **Feedback = Plan Change:** User feedback that changes scope/approach -> return to Plan
- **Tasks API drift:** Keep Tasks API updated in real-time
- **Missing logs:** Log Contract at Gate 1, Completion at Gate 2, Interaction on grade/improve
- **Mental model drift:** Don't assume you know the protocol - quote the actual section text
