# Tandem Protocol

A lightweight protocol reminder system for maintaining multi-phase project discipline across context compactions.

## What Is This?

The **Tandem Protocol** is a 5-step workflow for complex, multi-phase projects with approval checkpoints. It ensures:

- Plans are validated before implementation
- Work is documented with evidence files
- User approval gates critical transitions
- Completion is properly logged and committed

This implementation uses **attention activation** - the protocol is always in context (via CLAUDE.md @reference), and the `/tandem` command serves as a lightweight memory jogger when protocol compliance drifts.

## Choosing a Version

Two versions are available - choose based on your preference:

**Full Protocol** (`tandem-protocol.md`) - ~1,700 lines
- Complete explanations of why each step exists
- Detailed examples (good and bad patterns)
- Common failure modes and how to avoid them
- Extensive background and design rationale
- Best for: Learning the protocol, understanding the "why"

**Concise Protocol** (`tandem-protocol-concise.md`) - ~600 lines
- Mechanically prescriptive quick reference
- Mermaid flowchart + step-by-step pseudo-code
- Actual tool syntax (TodoWrite, AskUserQuestion)
- Verification templates with bash commands
- Platform-flexible (web UI, CLI tools, non-Claude agents)
- Best for: Daily use, quick lookups, minimal token usage

Both versions cover the same 5-step workflow. Choose the one that fits your needs, or switch between them anytime.

## Installation

### Quick Install (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/tandem-protocol/main/install.sh)
```

This clones to `~/tandem-protocol` and creates the `/tandem` command. Then add to your project's CLAUDE.md:

```markdown
# Tandem Protocol (choose one)

# Full version - with background & examples:
@~/tandem-protocol/tandem-protocol.md

# Concise version - mechanics only:
@~/tandem-protocol/tandem-protocol-concise.md
```

### Manual Install

If you prefer manual setup:

```bash
# 1. Clone to home directory
cd ~ && git clone https://github.com/YOUR_ORG/tandem-protocol.git

# 2. Create command symlink
mkdir -p ~/.claude/commands
ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md

# 3. Add to your project's CLAUDE.md (choose one version)

# Full version:
echo "" >> CLAUDE.md
echo "# Tandem Protocol" >> CLAUDE.md
echo "@~/tandem-protocol/tandem-protocol.md" >> CLAUDE.md

# OR Concise version:
echo "" >> CLAUDE.md
echo "# Tandem Protocol" >> CLAUDE.md
echo "@~/tandem-protocol/tandem-protocol-concise.md" >> CLAUDE.md
```

**Verify:** Start Claude Code, then run `/tandem`

### Alternative Installations

**For teams** (version-controlled with project):
```bash
git submodule add https://github.com/YOUR_ORG/tandem-protocol.git vendor/tandem-protocol

# Choose one version in CLAUDE.md:
echo "@vendor/tandem-protocol/tandem-protocol.md" >> CLAUDE.md
# OR
echo "@vendor/tandem-protocol/tandem-protocol-concise.md" >> CLAUDE.md
```

**For custom locations:**
Install anywhere, then reference with tilde or absolute path in CLAUDE.md:
- Full: `@~/your/path/tandem-protocol.md`
- Concise: `@~/your/path/tandem-protocol-concise.md`

**Advanced:** See [ADVANCED.md](./ADVANCED.md) for Docker, CI/CD, Windows WSL, monorepos, and more.

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

## Testing

This repository includes automated tests to verify installation and migration scripts work correctly.

### Run All Tests

```bash
bash tests/run_all.sh
```

### What's Tested

- ✅ URL validation (no placeholder URLs)
- ✅ Migration script (from env vars to tilde paths)
- ✅ Manual installation steps
- ✅ Quick install script

See [tests/README.md](./tests/README.md) for details.
