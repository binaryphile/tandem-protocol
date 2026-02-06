# Use Case: UC2 Plan Mode & File Distinction

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol under Claude Code)
**Secondary Actors:** User, Claude Code tool system

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Plan file vs contract file distinction | Other tool integrations (TodoWrite, etc.) |
| EnterPlanMode/ExitPlanMode timing | Plan mode UI/UX details |
| Content routing (HOW vs WHAT) | File format specifications |
| Integration points in protocol steps | Multi-agent coordination |
| Main success path only | Exceptional cases (Claude reasons through these) |

## System-in-Use Story

> Claude, executing Tandem Protocol for a user's feature request, needs to document its approach. It enters plan mode and writes methodology to the plan file: "Phase by use case, TDD for implementation." After getting user approval at Step 1c, Claude exits plan mode and creates the contract file with scope and success criteria. Claude likes this separation because the plan file persists across sessions for reference, while the contract tracks immediate deliverables. The user likes it because they can review "what we agreed" (contract) separately from "how we'll do it" (plan).

## Context of Use
When executing Tandem Protocol under Claude Code, the LLM must correctly use plan mode tools (EnterPlanMode, ExitPlanMode) and distinguish between plan file and contract file. Confusion causes content to land in wrong locations.

## Stakeholders & Interests
- User: Plan and contract serve different purposes; confusion breaks workflow
- LLM: Needs clear guidance on which file for which content
- Protocol: Maintains separation of concerns (HOW vs WHAT)

## Preconditions
- LLM is operating under Claude Code (or similar tool-enabled environment)
- EnterPlanMode and ExitPlanMode tools available
- Plan file location: `~/.claude/plans/`
- Contract file location: Project working directory

## Success Guarantee
- Plan file contains HOW (approach, methodology, research strategy)
- Contract file contains WHAT (scope, deliverables, success criteria)
- Plan mode entered before Step 1
- Plan mode exited at Step 1c (after approval, before contract creation)

## Minimal Guarantee
- No contract-style content in plan file
- No plan-style content in contract file
- User not confused by misplaced content

## Trigger
LLM begins Tandem Protocol execution under tool-enabled environment.

## Main Success Scenario
1. LLM receives task requiring planning
2. LLM enters plan mode (EnterPlanMode tool if available)
3. LLM writes approach/methodology to plan file
4. LLM executes Steps 1a-1c in plan mode (understanding, questions, approval)
5. LLM exits plan mode at Step 1c (ExitPlanMode tool)
6. LLM creates contract file in project directory (Step 1d)
7. LLM archives plan + contract to plan-log.md (Step 1e)

## Extensions
2a. EnterPlanMode tool not available:
    2a1. LLM presents plan in conversation instead
    2a2. Continue at step 4 (no plan file created)

3a. LLM writes contract-style content to plan file:
    3a1. VIOLATION - plan file should contain HOW, not WHAT
    3a2. At Step 1d, extract scope/deliverables from plan, write to contract instead
    3a3. Plan file retains only methodology; contract gets WHAT content

5a. ExitPlanMode tool not available:
    5a1. LLM notes plan mode not applicable
    5a2. Continue at step 6

6a. LLM writes plan-style content to contract file:
    6a1. VIOLATION - contract should contain WHAT, not HOW
    6a2. Remove methodology from contract, reference plan file instead

7a. Multi-phase work (plan persists across phases):
    7a1. Plan file retained for reference across UC phases
    7a2. Each phase gets new contract file
    7a3. Archive each contract to plan-log.md at completion

## Sub-Variations
- Step 3: Plan may include research strategy, phasing, methodology
- Step 6: Contract may include success criteria, deliverables, constraints

## Technology Variations
- Step 2/5: May use EnterPlanMode/ExitPlanMode or equivalent
- Step 6: Contract file may be markdown, yaml, or other format

## Guard Conditions (Behavioral Tests)

### Content-Based (grep plan/contract files)
| Condition | Expected Behavior |
|-----------|-------------------|
| Plan file contains "Success Criteria" | FAIL: Contract content in plan |
| Plan file contains "Deliverables" list | FAIL: Contract content in plan |
| Contract file contains "Methodology" | FAIL: Plan content in contract |
| Contract file contains "Research strategy" | FAIL: Plan content in contract |

### Tool-Invocation-Based (hook verification)
| Condition | Expected Behavior |
|-----------|-------------------|
| EnterPlanMode called after Step 1 starts | FAIL: Late entry |
| ExitPlanMode called before user approval | FAIL: Premature exit |
| ExitPlanMode not called before Write to contract | FAIL: Still in plan mode |
| Write to contract path while plan mode active | FAIL: Should exit first |

## File Content Guide

| Content Type | Belongs In | Example |
|--------------|------------|---------|
| Approach | Plan file | "Phase by use case, TDD for implementation" |
| Methodology | Plan file | "Deferred planning, efficiency constraints" |
| Research notes | Plan file | "Need to investigate X before Y" |
| Scope | Contract | "Implement Step 1b sequencing rule" |
| Success criteria | Contract | "1. [ ] Step 2: Complete deliverable" |
| Deliverables | Contract | "Modified tandem-protocol.md" |

**Protocol format requirements:**
- Step numbering starts at 1 (not 0)
- All steps in Mermaid diagram must have "Step X" format (e.g., "Step 6a: Mark APPROVED")
- Logically grouped steps use subletters for telescoping (6a, 6b, 6c, 6d)
- Success criteria should be numbered and reference protocol step numbers (e.g., "Step 3: Complete deliverable")

## Integration Points in Protocol

| Step | Guidance Needed |
|------|-----------------|
| Before Step 1 | Enter plan mode if tool available |
| Step 1a-1c | Execute in plan mode |
| Step 1c | Exit plan mode after approval |
| Step 1d | Create contract (now outside plan mode) |
| Step 1e | Archive both files |

## Project Info
- Priority: P1 (High) - High frequency compliance failure
- Frequency: Every protocol execution under Claude Code
- Behavioral Goal Impact: Strengthens existing goals, +0 new goals
