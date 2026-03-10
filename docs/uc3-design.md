# UC3 Design: Plan Mode Entry Sequence

## Design

**Location:** README.md - Step 1c (existing-plan guidance), CLAUDE.md (Plan Mode Entry)
**Design principle:** Protocol covers the main success path only. Exceptional cases omitted — Claude can reason through these without explicit guidance.

### Mechanism

Step 1c sequence:
1. `EnterPlanMode` (creates `~/.claude/plans/<name>.md`)
2. If existing plan (system-reminder shows plan content):
   - Quote plan verbatim (no summarizing)
   - Grade analysis: "Do I understand this?"
   - Grade plan quality: "Is this sound?"
   - Wait for user direction before proceeding
3. Otherwise: create new plan
4. On approval: `ExitPlanMode`, execute Implementation Gate bash block

### Pseudocode

```python
# Plan mode entry
EnterPlanMode()

# If existing plan appears in system-reminder
plan_file = find_plan("~/.claude/plans/")
if plan_file:
    present(f"```\n{read(plan_file)}\n```")  # VERBATIM
    present(grade_analysis())   # "Do I understand this?" — FIRST
    present(grade_plan())       # "Is this sound?" — SECOND
    direction = wait_for("improve", "proceed")  # BLOCKING
    if direction == "improve":
        address_deductions()
        # Loop back to re-grade

# On approval
ExitPlanMode()
# Execute Implementation Gate bash block:
#   evtctl contract '<json>'
#   evtctl task "description"
```

### Integration Points

| Protocol Step | Action |
|---------------|--------|
| Step 1c (Design) | Enter plan mode, check for existing plan |
| Step 1d (Present) | Quote verbatim, grade, wait for direction |
| Step 2 (Impl Gate) | On approval: exit plan mode, publish contract via `evtctl contract '<json>'` |
| CLAUDE.md | Reinforces: quote verbatim, grade, wait |

### File Content at Each Step

| Content Type | Belongs In | Example |
|--------------|------------|---------|
| Plan contents | Verbatim quote block | `` ```\n[exact plan text]\n``` `` |
| Analysis grade | After quote | "Analysis Grade: B+ — understood scope but missed constraint" |
| Plan grade | After analysis | "Plan Grade: A- — sound approach, minor ordering issue" |
| Direction prompt | After grades | "Improve or proceed?" |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Quote verbatim guidance | `[Qq]uote.*verbatim\|VERBATIM\|no summar` |
| T2 | Analysis grade before plan grade | `analysis.*FIRST\|grade.*analysis` |
| T3 | BLOCKING wait for direction | `[Ww]ait.*direction\|BLOCKING` |
| T4 | Improve path | `address.*deductions\|improve` |
