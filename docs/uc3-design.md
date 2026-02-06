# UC3-B Design: Plan Mode Entry Sequence

## Design

**Location:** tandem-protocol.md - Step 2 start

**Design principle:** Protocol covers the main success path only. Exceptional cases (no existing plan, file too large, etc.) are omitted - Claude can reason through these without explicit guidance. This maintains protocol efficiency.

Step 2 sequence:
1. Check for leftover contracts, clear if needed
2. Enter plan mode
3. If existing plan: quote verbatim, grade /a then /p, wait for direction
4. Continue to Step 2a (present understanding)

## Pseudocode

**Location:** Step 2 start

```python
# STEP 2 START: Contract cleanup + Plan mode entry

# 1a. Check for leftover contracts
contracts = ls("*-contract.md")
if contracts:
    action = ask("Incomplete work found. Abandon or complete first?")
    if action == "abandon":
        delete(contracts)
    else:
        # Complete previous work first
        resume_at_step_4()

# 1b. Enter plan mode
if tool_available("EnterPlanMode"):
    EnterPlanMode()

# 1c. If existing plan, quote and grade
plan_file = find_plan("~/.claude/plans/")
if plan_file:
    # Quote VERBATIM - no summarizing
    present(f"```\n{read(plan_file)}\n```")

    # Analysis grade FIRST (/a)
    present(grade_analysis())  # "Do I understand this?"

    # Plan grade SECOND (/p)
    present(grade_plan())  # "Is this sound?"

    # BLOCKING: wait for direction
    wait_for("improve", "proceed")

# Continue to Step 2a (present understanding)...
```

## Post-Proceed Flow (Reference)

After user says "proceed" and work completes:

```python
# Step 6: Post-Approval (existing protocol)
contract.status = "APPROVED"

# Archive with intro line, then append file literally
plan_log.append(f"## {phase_name} Contract: Archived Verbatim {date}\n\n")
cat(contract) >> plan_log  # Append file contents directly
delete(contract)
```

Intro line format: `## [Subject]: Archived Verbatim [Date]`

**Line impact:** +20 lines (entry sequence only - archiving is existing Step 6)

## Behavioral Test Cases (for UC3-C)

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Quote verbatim guidance | `[Qq]uote.*verbatim\|VERBATIM\|no summar` |
| T2 | Analysis grade before plan grade | `analysis.*FIRST\|/a.*before\|grade.*analysis.*grade.*plan` |
| T3 | BLOCKING wait for direction | `BLOCKING.*wait\|wait.*direction` |
| T4 | Improve path (all deductions) | `improve.*ALL\|ALL.*deductions\|address.*deductions` |

## Integration Points

- **tandem-protocol.md:** Step 2 start
- **Mermaid diagram:** Step 2 includes contract check + plan mode entry

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
1. Add Plan Mode Entry section to tandem-protocol.md
2. Verify tests PASS

### Phase 3: REFACTOR
1. Tune for efficiency (target: ≤+20 lines)
2. Verify tests still pass
