# Tandem Protocol

A lightweight protocol reminder system for maintaining multi-phase project discipline across context compactions.

## What Is This?

The **Tandem Protocol** is a 5-step workflow for complex, multi-phase projects with approval checkpoints. It ensures:

- Plans are validated before implementation
- Work is documented with evidence files
- User approval gates critical transitions
- Completion is properly logged and committed

This implementation uses **attention activation** - the protocol is always in context (via CLAUDE.md @reference), and the `/tandem` command serves as a lightweight memory jogger when protocol compliance drifts.

## Installation

### 1. Add protocol to project context

Create or edit `CLAUDE.md` in your project root:

```markdown
# Project Context

@$TANDEM_PROTOCOL_DIR/tandem-protocol.md

<!-- rest of your project context -->
```

**Path:** `$PROJECT_ROOT/CLAUDE.md` (project root, NOT `.claude/CLAUDE.md`)

### 2. Install the command

```bash
mkdir -p ~/.claude/commands

ln -sf $TANDEM_PROTOCOL_DIR/tandem.md ~/.claude/commands/
```

### 3. Reload Claude Code

Exit and restart Claude Code to load the command.

## Usage

### When to use `/tandem`

Invoke 1-2 times early in your session, or whenever you notice protocol drift:

- At session start (before planning)
- When about to implement without approval
- When uncertain about current step
- After context compaction
- When approaching approval boundaries

### How it works

The command doesn't reproduce the protocol - it **activates your attention** to the protocol already in context:

1. Full protocol is in CLAUDE.md (via @reference)
2. CLAUDE.md doesn't get compacted (always available)
3. `/tandem` reminds you to check the protocol
4. Repeated emphasis beats the attention curve

### Example workflow

```
User: "Add a new feature for user authentication"

You: /tandem
[Check protocol - see we're starting new work]
[Follow Step 1: Create plan, present to user, get approval]

User: "proceed"

You: [Follow Step 2: Implement]
[Follow Step 3: Update evidence]
[Follow Step 4: Present deliverables and WAIT]

User: "approved"

You: [Follow Step 5: Log and commit]
```

## The 5 Steps (Quick Reference)

0. **Evidence cleanup** (new planning sessions only)
1. **Plan validation + approval** (never skip!)
2. **Implementation** (actual work)
3. **Checkpoint preparation** (update evidence, add AWAITING footer)
4. **Present and WAIT** (explicit approval required)
5. **Post-approval** (evidence → plan-log → commit)

## Design Philosophy

**Why not Skills?** Skills get summarized during compaction, requiring refresh.

**Why not Hooks?** Session-start hooks don't solve mid-session compaction drift.

**Why not full protocol in command?** Heavy reproduction wastes tokens; protocol is already in context.

**Why this approach?** Combines best of all:
- Protocol survives compaction (in CLAUDE.md)
- Lightweight activation on demand
- Repeated emphasis maintains compliance
