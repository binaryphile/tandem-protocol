# Tandem Protocol Behavioral Test Results

> **Note:** These experiments tested plan-log conditional execution. Based on findings,
> the protocol was updated to use direct `plan-history.md` append instead of plan-log.
> See `variant-exp7-new-protocol.md` for the updated approach.

## Summary

**All protocol format variations achieved 100% compliance** when tool availability was explicitly stated.

The negative control (0% compliance when plan-log wasn't mentioned) validated the methodology.

## Results

| Experiment | Description | Variant A | Variant B |
|------------|-------------|-----------|-----------|
| 0 | Baseline (current protocol) | 100% | - |
| 1 | Code block vs prose format | 100% | 100% |
| 2 | Optional vs imperative framing | 100% | 100% |
| 3 | Environment inventory | 100% | 100% |
| 4 | Quote requirement | 100% | 100% |
| 5 | Condition markers (emoji) | 100% | 100% |
| 6 | Negative control (no plan-log mention) | - | 0% |

n=3 trials per variant

## Key Finding

**The protocol format doesn't matter.** What matters is explicit tool availability.

All variants included this line:
```
**Environment:** plan-log command is AVAILABLE (`cat file | plan-log`)
```

With this explicit statement, Claude executed plan-log 100% of the time regardless of:
- Code block vs prose format
- "Optional" vs "imperative" framing
- Presence of inventory checklist
- Quote requirements
- Emoji condition markers

## Root Cause Analysis

The original observed failures (Claude skipping plan-log in interactive sessions) weren't caused by:
- ❌ Conditions inside code blocks being skipped
- ❌ "Optional" framing permitting skipping
- ❌ Lack of environment inventory
- ❌ Mental model drift
- ❌ Insufficient visual weight on conditions

The actual cause:
- ✅ **Implicit vs explicit tool availability** - Claude doesn't proactively check what tools exist; it needs to be told

## Implications for the Protocol

### Problem
The protocol says `if plan_log_available:` but never explicitly establishes that plan-log IS available. In interactive mode:
1. Skills are listed in system prompt under `available_skills`
2. Claude doesn't automatically cross-reference this list when evaluating protocol conditionals
3. Without explicit statement, Claude treats conditionals as "unknown → skip"

### Solution Options

1. **Add environment statement to protocol preamble:**
   ```markdown
   ## Environment Check
   Before executing, verify which tools from this list are in your available_skills:
   - plan-log (for contract logging)
   - git (for commits)
   - TodoWrite (for task tracking)
   ```

2. **Make skill invocation explicit in Step 5c:**
   ```markdown
   ### Step 5c: Handle Contract

   Check your available_skills for "plan-log". If present:
   1. Use the Skill tool to invoke plan-log with the contract contents
   2. Delete the contract file
   ```

3. **Use /tandem skill to inject availability:**
   The /tandem skill reminder could include:
   ```
   **Available tools for this protocol:** plan-log, git, TodoWrite
   ```

### Recommended Change

Add to the protocol preamble (before Step 0):
```markdown
## Tool Availability
This protocol uses these tools when available. Check your context to confirm availability:
- **plan-log**: Bash command for logging contracts (`cat file | plan-log`)
- **git**: For committing deliverables
- **TodoWrite**: For tracking step progress
```

This makes tool availability explicit upfront, which the experiments showed produces 100% compliance.

## Test Artifacts

- Test harness: `experiments/test-harness.sh`
- Scenario: `experiments/scenario-step5c.md`
- Variants: `experiments/variant-exp*.md`
- Results: `/tmp/tandem-test/`
