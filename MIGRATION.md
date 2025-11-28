# Migration Guide

This guide helps you migrate from older Tandem Protocol installations to the current tilde-based approach.

---

## Migrating from Environment Variables

If your CLAUDE.md files reference `@$TANDEM_PROTOCOL_DIR/tandem-protocol.md`, you need to migrate to supported @reference syntax.

### Why Migrate?

Environment variable expansion in @references (`@$VAR/path`) is not documented by Claude Code. Documented syntax uses:
- Tilde paths: `@~/path/file.md`
- Absolute paths: `@/absolute/path/file.md`
- Relative paths: `@relative/path/file.md`

### Migration Steps

#### Step 1: Find Your Current Installation

```bash
echo $TANDEM_PROTOCOL_DIR
# Example output: /home/you/projects/share/tandem-protocol
```

If not set or you want a fresh start, see [README.md](./README.md) for installation.

#### Step 2: Determine Your New Reference Syntax

**If installed in home directory** (recommended):

```bash
# If: /home/you/projects/share/tandem-protocol
# Or: /home/you/tandem-protocol
# Use tilde syntax:
@~/tandem-protocol/tandem-protocol.md
# or:
@~/projects/share/tandem-protocol/tandem-protocol.md
```

**If installed system-wide or custom location:**

```bash
# Use absolute path:
@/opt/tandem-protocol/tandem-protocol.md
# or whatever your actual path is
```

#### Step 3: Update CLAUDE.md Files

**Manual update (one file):**

```bash
# Edit your project's CLAUDE.md
# Find: @$TANDEM_PROTOCOL_DIR/tandem-protocol.md
# Replace with: @~/tandem-protocol/tandem-protocol.md
```

**Bulk update (all projects):**

```bash
# For ~/tandem-protocol installation:
find ~/projects -name "CLAUDE.md" -type f -exec \
  sed -i.bak 's|@\$TANDEM_PROTOCOL_DIR/tandem-protocol.md|@~/tandem-protocol/tandem-protocol.md|g' {} \;

# For other locations, adjust the replacement path accordingly
```

**Note:** This creates `.bak` backup files. The `-i` flag works on both macOS and Linux, but some GNU sed versions might need `-i.bak` with the extension.

#### Step 4: Remove Environment Variable (Optional)

```bash
# Remove from ~/.bashrc, ~/.zshrc, ~/.profile, etc.
# Delete or comment out:
# export TANDEM_PROTOCOL_DIR="..."

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

#### Step 5: Verify

```bash
# Start Claude Code in a project
cd your-project
claude

# Run /memory to see loaded files
> /memory
# Look for tandem-protocol.md in the list

# Or test directly
> /tandem
# Should show protocol reminder
```

---

## Migrating from Old Location (urma-next-obsidian)

If you were using the original Task Completion Protocol from urma-next-obsidian:

### Step 1: Install Tandem Protocol

Follow [README.md](./README.md) installation instructions.

### Step 2: Update References

**Find:**
```markdown
@/home/user/projects/urma-next-obsidian/guides/task-completion-protocol.md
```

**Replace with:**
```markdown
@~/tandem-protocol/tandem-protocol.md
```

### Step 3: Update Terminology

The protocol has been renamed:
- "Task Completion Protocol" → "Tandem Protocol"
- "task-completion-protocol" → "tandem-protocol"

Content and steps remain the same.

---

## Troubleshooting Migration

### Changes Not Taking Effect

```bash
# 1. Verify file exists
ls -la ~/tandem-protocol/tandem-protocol.md

# 2. Check CLAUDE.md has correct reference
cat CLAUDE.md | grep tandem

# 3. Restart Claude Code
# Exit and restart to reload CLAUDE.md
```

### Sed Command Fails

**macOS vs Linux differences:**

```bash
# macOS (BSD sed):
sed -i .bak 's|old|new|g' file

# Linux (GNU sed):
sed -i.bak 's|old|new|g' file

# Portable version (works on both):
sed -i.bak 's|old|new|g' file
```

### Rollback Migration

If something went wrong:

```bash
# Restore from backups
find ~/projects -name "CLAUDE.md.bak" -type f | while read backup; do
  original="${backup%.bak}"
  mv "$backup" "$original"
done
```

### Path Doesn't Match

If you cloned to a different location:

```bash
# Find where you actually installed it
find ~ -name "tandem-protocol.md" -type f 2>/dev/null | grep tandem

# Use that path in your CLAUDE.md references
# Example: @~/tools/tandem-protocol/tandem-protocol.md
```

---

## Post-Migration Checklist

- [ ] Protocol file exists at expected location
- [ ] CLAUDE.md has correct @reference syntax
- [ ] `/tandem` command works
- [ ] `/memory` shows tandem-protocol.md loaded
- [ ] Environment variable removed (if desired)
- [ ] Backup `.bak` files cleaned up (after verification)

---

## See Also

- [README.md](./README.md) - Installation guide
- [ADVANCED.md](./ADVANCED.md) - Special environments and edge cases
