# Migrating to Self-Contained Tandem Protocol

If you have existing projects using the old Task Completion Protocol location, follow these steps:

## Step 1: Update CLAUDE.md References

**Find:** `@/home/ted/projects/urma-next-obsidian/guides/task-completion-protocol.md`
**Replace:** `@$TANDEM_PROTOCOL_DIR/tandem-protocol.md`

## Step 2: Set Environment Variable

Add to your shell profile (~/.bashrc, ~/.zshrc, etc.):

```bash
export TANDEM_PROTOCOL_DIR="$HOME/projects/share/tandem-protocol"
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Step 3: Install the Command

Symlink the command to your commands directory:

```bash
ln -sf $TANDEM_PROTOCOL_DIR/tandem.md ~/.claude/commands/
```

## Step 4: Update Documentation

Search your project for references to "task-completion-protocol" and update to "tandem-protocol" where appropriate.

## What About the Old File?

The old file at `/home/ted/projects/urma-next-obsidian/guides/task-completion-protocol.md` is left untouched. You can:
- Keep it for reference
- Archive it
- Use it for projects that haven't migrated yet

The new file is the source of truth going forward.

## Terminology Changes

- "Task Completion Protocol" → "Tandem Protocol"
- "task-completion-protocol" → "tandem-protocol"
- References to "Ted" → "user"

The protocol content remains the same, only the name and references have changed for clarity and portability.
