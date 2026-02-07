# Advanced Features

## Self-Grading & Improve Cycles

At each approval gate, you can ask Claude to grade its own work before deciding whether to proceed.

```mermaid
flowchart TD
    G2{"GATE 2<br/>May I proceed?"} -->|"Grade your work"| GRADE["Grade: A- (93/100)<br/>- deduction 1<br/>- deduction 2"]
    GRADE -->|"Improve"| IMPROVE["Address deductions"]
    IMPROVE --> G2
    G2 -->|"Approve"| S4["Step 4: Log + Commit"]

    style G2 fill:#fff3e0,stroke:#ff9800
    style GRADE fill:#e8f5e9,stroke:#388e3c
```

The grading cycle works at both gates. Use it for complex or high-stakes work.

## Event Logging

All protocol events are logged directly to `plan-log.md` using timestamped entries:

| Entry Type | When | Example |
|------------|------|---------|
| **Contract** | Step 1d (phase start) | `Contract: Phase 1 - auth \| [ ] middleware, [ ] tests` |
| **Completion** | Results delivered | `Completion: Step 2 \| [x] middleware (auth.go:45)` |
| **Interaction** | User feedback | `Interaction: grade → B/84, missing edge case` |

**Format:** `YYYY-MM-DDTHH:MM:SSZ | Type: description`

The Contract/Completion checkbox pattern ensures criteria verification is explicit - can't claim "3/3 met" without evidence.

## IAPI Cognitive Stages

The protocol uses the IAPI model for cognitive stages:

| Stage | Step | Description |
|-------|------|-------------|
| **I**nvestigate | Plan Mode | Explore codebase, gather context |
| **A**nalyze | 1a-1b | Understand requirements, ask questions |
| **P**lan | 1c-1e | Design approach, get approval |
| **I**mplement | 2 | Execute the work |

Each I/A/P stage can use subagents that read domain guides and return structured output with lessons applied/missed.

## Multi-Phase Projects

For projects spanning multiple sessions or requiring distinct phases:

```mermaid
flowchart TD
    START(["Start"]) -->|"Make a plan to..."| S1["Step 1: Plan Validation"]
    S1 --> G1{"GATE 1<br/>May I proceed?"}
    G1 -->|"Approve"| S2["Step 2: Implementation"]
    S2 --> S3["Step 3: Present Results"]
    S3 --> G2{"GATE 2<br/>May I proceed?"}
    G2 -->|"Approve"| S4["Step 4: Log + Commit"]
    S4 --> DONE(["Done / Next phase"])

    style G1 fill:#fff3e0,stroke:#ff9800
    style G2 fill:#fff3e0,stroke:#ff9800
```

Each phase follows the same 4-step workflow. Plan files persist across sessions, and the event log maintains continuity.

## Design Philosophy

**Why not Skills?** Skills get summarized during compaction, requiring refresh.

**Why not Hooks?** Session-start hooks don't solve mid-session compliance drift.

**Why not full protocol in command?** Heavy reproduction wastes tokens; protocol is already in context.

**Why this approach?** Combines best of all:
- Protocol in CLAUDE.md (always available via @reference)
- Lightweight activation on demand
- Repeated emphasis maintains compliance
