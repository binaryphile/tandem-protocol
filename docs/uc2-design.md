# UC2 Design: Plan Mode & Content Distinction

## Design

**Location:** README.md Step 1c (plan template, HOW/WHAT distinction line)

**Design principle:** Plan file = HOW (approach, changes). Contract = WHAT (criteria) — published to Era via `mk contract` at the Implementation Gate, not stored in the plan file.

### Tool Mapping

| UC Step | Tool/Mechanism |
|---------|---------------|
| Enter plan mode | `EnterPlanMode` tool |
| Write plan | Edit `~/.claude/plans/<name>.md` |
| Exit plan mode | `ExitPlanMode` tool |
| Publish contract | `mk contract "criteria"` at Implementation Gate |

### Content Routing

| Content Type | Belongs In | Mechanism |
|--------------|------------|-----------|
| Approach | Plan file (`~/.claude/plans/`) | Written during plan mode |
| Methodology | Plan file | Written during plan mode |
| Research notes | Plan file | Written during plan mode |
| Scope | Contract event | `mk contract` at Implementation Gate |
| Success criteria | Contract event | `mk contract` at Implementation Gate |
| Deliverables | Contract event | `mk contract` at Implementation Gate |

### Integration Points

| Protocol Step | Action |
|---------------|--------|
| Step 1c (Design) | Enter plan mode, write plan file |
| Step 1d (Present) | Validate plan, exit plan mode |
| Step 2 (Impl Gate) | Publish contract via `mk contract` |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Plan file = HOW | `[Pp]lan file.*HOW\|HOW.*plan` |
| T2 | Contract = WHAT | `[Cc]ontract.*WHAT\|WHAT.*[Cc]ontract` |
| T3 | Plan file location | `~/.claude/plans/\|plans/` |
| T4 | mk contract at gate | `mk contract` |
