# UC2-B Design: Plan Mode & Content Distinction Integration

## Current State Analysis

**Location:** tandem-protocol.md Step 1c

**Current pseudocode:**
```python
# Exit plan mode - enables write operations
if tool_available("ExitPlanMode"):
    ExitPlanMode()
    # DISTINCTION (HOW vs WHAT):
    # Plan file (~/.claude/plans/): HOW - approach, methodology, phasing
    # Contract entry (plan-log.md): WHAT - scope, deliverables, success criteria
    # Plan persists across phases; Contract entry captures per-phase scope
```

**Status:** Implemented. File distinction is now plan file vs Contract entry (not contract file).

## Design Changes

No changes needed - the protocol already contains the HOW vs WHAT distinction.

**Note:** UC7 eliminated contract files in favor of direct logging to plan-log.md:
- **Before:** Contract file in project directory
- **After:** Contract entry timestamped in plan-log.md

## Behavioral Test Cases (for UC2-C)

Tests verify tandem-protocol.md contains the required guidance.

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Plan file = HOW | `[Pp]lan file.*HOW\|HOW.*plan` |
| T2 | Contract entry = WHAT | `[Cc]ontract.*WHAT\|WHAT.*[Cc]ontract` |
| T3 | Plan file location | `~/.claude/plans/\|plans/` |
| T4 | Plan persists across phases | `persist.*phase\|across.*phase` |

**Test Logic:** PASS if pattern found in Step 1c section of tandem-protocol.md
