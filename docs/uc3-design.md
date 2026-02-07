# UC3-B Design: Plan Mode Entry Sequence

## Design

**Location:** README.md - Step 1 start 
**Design principle:** Protocol covers the main success path only. Exceptional cases (no existing plan, file too large, etc.) are omitted - Claude can reason through these without explicit guidance. This maintains protocol efficiency.

Step 1 sequence:
1. Enter plan mode
2. If existing plan: quote verbatim, grade /a then /p, wait for direction
3. Present understanding + "Upon approval I will..." + "May I proceed?"
4. On approval: exit plan mode, log Contract entry to plan-log.md
5. Log Completion entry for Step 1
6. Continue to Step 2 (complete deliverable)

## Pseudocode

**Location:** Step 2 start

```python
# STEP 1 START: Plan mode entry 
# 1a. Enter plan mode
if tool_available("EnterPlanMode"):
    EnterPlanMode()

# 1b. If existing plan, quote and grade
plan_file = find_plan("~/.claude/plans/")
if plan_file:
    # Quote VERBATIM - no summarizing
    present(f"```\n{read(plan_file)}\n```")

    # Analysis grade FIRST (/a)
    present(grade_analysis())  # "Do I understand this?"

    # Plan grade SECOND (/p)
    present(grade_plan())  # "Is this sound?"

    # BLOCKING: wait for direction on grades
    direction = wait_for("improve", "proceed")

    if direction == "improve":
        address_deductions()
        # Loop back to re-grade

# 1c. APPROVAL GATE: Re-present understanding + what happens on proceed
present(f"""
## Plan Ready for Approval

**Objective:** [from understanding]
**Success criteria:** [count] items
**Approach:** [summary]

**Upon your approval, I will:**
1. Exit plan mode
2. Log Contract entry to plan-log.md (scope/criteria)
3. Log Completion entry for Step 1
4. Proceed to Step 2 (complete deliverable)

**May I proceed?**
""")

# BLOCKING: wait for explicit approval
wait_for("proceed", "yes", "approved")

# 1d. Exit plan mode - enables write operations
if tool_available("ExitPlanMode"):
    ExitPlanMode()

# Continue to Step 1d (create contract)...
```

## Step 1d-1e: Log Contract and Completion (after approval)

After user says "proceed":

```python
# Step 1d: Log Contract entry (captures "what we agreed to")
timestamp = datetime.now().isoformat() + "Z"
criteria_checkboxes = ", ".join([f"[ ] {c}" for c in success_criteria])
contract_entry = f"{timestamp} | Contract: Phase {N} - {objective} | {criteria_checkboxes}"
append_to_log("plan-log.md", contract_entry)

# Example: 2026-02-06T14:30:00Z | Contract: Phase 1 - auth | [ ] middleware, [ ] tests, [ ] docs

# Step 1e: Log Completion entry for Step 1
completion_entry = f"{timestamp} | Completion: Step 1 - plan validated, approval received"
append_to_log("plan-log.md", completion_entry)
```

**Entry format:** See UC7 for Contract/Completion entry details

## Behavioral Test Cases (for UC3-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Quote verbatim guidance | `[Qq]uote.*verbatim\|VERBATIM\|no summar` |
| T2 | Analysis grade before plan grade | `analysis.*FIRST\|/a.*before\|grade.*analysis.*grade.*plan` |
| T3 | BLOCKING wait for direction | `BLOCKING.*wait\|wait.*direction` |
| T4 | Improve path (all deductions) | `improve.*ALL\|ALL.*deductions\|address.*deductions` |

## Integration Points

- **README.md:** Step 1 start - **Mermaid diagram:** Step 1 is Plan Validation (no contract check)

## Line Budget

| Item | Lines |
|------|-------|
| Plan mode entry pseudocode | +20 |
| **Net** | **+20** |

Compliance buffer: UC1 (+5) + UC2 (+2) + UC3 (+20) = +27 of +30 available.

## UC3-C Implementation Sequence (Red/Green TDD)

### Phase 1: RED
1. Create `tests/uc3-plan-mode-entry.sh` with T1-T4 tests
2. Run against current protocol
3. Verify tests FAIL

### Phase 2: GREEN
1. Add Plan Mode Entry section to README.md
2. Verify tests PASS

### Phase 3: REFACTOR
1. Tune for efficiency (target: ≤+20 lines)
2. Verify tests still pass
