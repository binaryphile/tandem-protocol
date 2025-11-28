# Tandem Protocol: Advanced Installation

This guide covers edge cases, special environments, and advanced scenarios.

**For standard installation, see [README.md](./README.md).**

---

## Table of Contents

- [Docker/Containers](#dockercontainers)
- [CI/CD](#cicd)
- [Windows WSL](#windows-wsl)
- [Monorepos](#monorepos)
- [Multiple Versions](#multiple-versions)
- [Network Filesystems](#network-filesystems)
- [Readonly Filesystems](#readonly-filesystems)
- [Air-Gapped Environments](#air-gapped-environments)
- [Troubleshooting](#troubleshooting-advanced-issues)

---

## Docker/Containers

### Option 1: Copy at Build Time

```dockerfile
FROM your-base-image

# Copy protocol into container
COPY tandem-protocol /opt/tandem-protocol

# Add to CLAUDE.md
RUN echo "@/opt/tandem-protocol/tandem-protocol.md" >> /workspace/CLAUDE.md
```

### Option 2: Mount as Volume

```yaml
# docker-compose.yml
services:
  dev:
    volumes:
      - ./tandem-protocol:/workspace/tandem-protocol:ro
```

```markdown
# In CLAUDE.md
@/workspace/tandem-protocol/tandem-protocol.md
```

---

## CI/CD

### GitHub Actions

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Tandem Protocol
        run: |
          git clone https://github.com/YOUR_ORG/tandem-protocol.git /tmp/tandem
          echo "@/tmp/tandem/tandem-protocol.md" >> CLAUDE.md

      - name: Run Claude Code
        run: claude "run tests following tandem protocol"
```

### GitLab CI

```yaml
before_script:
  - git clone https://github.com/YOUR_ORG/tandem-protocol.git /builds/tandem
  - echo "@/builds/tandem/tandem-protocol.md" >> CLAUDE.md

test:
  script:
    - claude "run tests following tandem protocol"
```

---

## Windows WSL

Installation is identical to Linux:

```bash
# In WSL terminal
cd ~
git clone https://github.com/YOUR_ORG/tandem-protocol.git
ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md
```

**Reference in CLAUDE.md:**
```markdown
@~/tandem-protocol/tandem-protocol.md
```

**Note:** Tilde (`~`) expansion works correctly in WSL.

---

## Monorepos

### Option 1: Single Copy at Root

```
monorepo/
├── CLAUDE.md                    # @vendor/tandem-protocol/tandem-protocol.md
├── vendor/
│   └── tandem-protocol/
├── apps/
│   ├── web/
│   │   └── CLAUDE.md            # @../../vendor/tandem-protocol/tandem-protocol.md
│   └── api/
│       └── CLAUDE.md            # @../../vendor/tandem-protocol/tandem-protocol.md
```

### Option 2: Global Installation

Each project references your global install:

```markdown
# In each app's CLAUDE.md
@~/tandem-protocol/tandem-protocol.md
```

---

## Multiple Versions

**Problem:** Project A needs protocol v1.0, Project B needs v2.0

### Solution 1: Project-Local Copies

```bash
# Project A
cd project-a
git submodule add -b v1.0 https://github.com/YOUR_ORG/tandem-protocol.git vendor/tandem
echo "@vendor/tandem/tandem-protocol.md" >> CLAUDE.md

# Project B
cd project-b
git submodule add -b v2.0 https://github.com/YOUR_ORG/tandem-protocol.git vendor/tandem
echo "@vendor/tandem/tandem-protocol.md" >> CLAUDE.md
```

### Solution 2: Multiple Global Installs

```bash
# Install both versions
git clone -b v1.0 https://github.com/YOUR_ORG/tandem-protocol.git ~/tandem-v1
git clone -b v2.0 https://github.com/YOUR_ORG/tandem-protocol.git ~/tandem-v2

# Reference appropriate version in each project
# Project A CLAUDE.md: @~/tandem-v1/tandem-protocol.md
# Project B CLAUDE.md: @~/tandem-v2/tandem-protocol.md
```

---

## Network Filesystems

If protocol is on NFS/SMB mount:

```bash
# Example: /mnt/shared/protocols/tandem
ln -sf /mnt/shared/protocols/tandem/tandem.md ~/.claude/commands/tandem.md
```

**In CLAUDE.md:**
```markdown
@/mnt/shared/protocols/tandem/tandem-protocol.md
```

**Caution:** Network latency may slow Claude Code startup.

---

## Readonly Filesystems

If you can't write to `~/.claude/commands/`:

### Option 1: Project-Local Command

```bash
mkdir -p .claude/commands
ln -sf ~/tandem-protocol/tandem.md .claude/commands/tandem.md
```

### Option 2: No Symlink

Skip the `/tandem` command, load protocol via CLAUDE.md only.

---

## Air-Gapped Environments

**No internet access:**

**On internet-connected machine:**
```bash
git clone https://github.com/YOUR_ORG/tandem-protocol.git
tar -czf tandem-protocol.tar.gz tandem-protocol/
# Transfer tandem-protocol.tar.gz to air-gapped machine
```

**On air-gapped machine:**
```bash
tar -xzf tandem-protocol.tar.gz -C ~/
ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md
echo "@~/tandem-protocol/tandem-protocol.md" >> CLAUDE.md
```

---

## Troubleshooting Advanced Issues

### Permission Denied

```bash
# If you can't write to ~/.claude/
# Use project-local installation instead
mkdir -p .claude/commands
cp ~/tandem-protocol/tandem.md .claude/commands/
```

### Broken Symlinks

```bash
# Find broken symlinks
find ~/.claude/commands -xtype l

# Recreate
ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md
```

### Protocol Updates Not Reflected

```bash
# Update installation
cd ~/tandem-protocol && git pull

# Restart Claude Code
# Symlink automatically uses latest version
```

### File Not Found in Claude Code

**Symptom:** `/memory` doesn't show tandem-protocol.md

**Debug:**
```bash
# 1. Verify file exists
ls -la ~/tandem-protocol/tandem-protocol.md

# 2. Check CLAUDE.md reference
cat CLAUDE.md | grep tandem

# 3. Test path expansion
claude
> @~/tandem-protocol/tandem-protocol.md
# Should load the file
```

**Common causes:**
- Typo in path
- File doesn't exist at location
- @reference inside code block (won't evaluate)
- Wrong tilde expansion

### Different Paths on Different Machines

**Problem:** Developer A has `~/tools/tandem`, Developer B has `~/dev/protocols/tandem`

**Solution 1: Standardize** (recommended)
```bash
# Team decision: Everyone uses ~/tandem-protocol
# Document in team onboarding
```

**Solution 2: Project-local copy**
```bash
# Both developers:
git submodule add https://github.com/YOUR_ORG/tandem-protocol.git vendor/tandem
echo "@vendor/tandem/tandem-protocol.md" >> CLAUDE.md
# Now everyone has same path: @vendor/tandem/tandem-protocol.md
```

---

## See Also

- [README.md](./README.md) - Standard installation
- [MIGRATION.md](./MIGRATION.md) - Migrating from environment variables
