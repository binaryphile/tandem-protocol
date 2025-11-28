# Tandem Protocol Test Suite

Automated tests for installation scripts and documentation.

## Running Tests

### All Tests

```bash
bash tests/run_all.sh
```

### Individual Tests

```bash
bash tests/test_urls.sh            # Validate no placeholder URLs
bash tests/test_migration.sh       # Test migration script
bash tests/test_manual_install.sh  # Test manual installation steps
bash tests/test_quick_install.sh   # Test install.sh script
```

## What Each Test Does

### test_urls.sh
Validates that all documentation files (README.md, ADVANCED.md, MIGRATION.md, install.sh) don't contain placeholder URLs like `USER` or broken references.

### test_migration.sh
Tests the migration script from MIGRATION.md that converts:
- `@$TANDEM_PROTOCOL_DIR/tandem-protocol.md` → `@~/tandem-protocol/tandem-protocol.md`

Verifies:
- Old syntax is replaced
- Backup files are created
- Multiple projects are handled correctly

### test_manual_install.sh
Tests the manual installation steps from README.md:
1. Clone/copy repository
2. Create symlink to `~/.claude/commands/tandem.md`
3. Add reference to CLAUDE.md

### test_quick_install.sh
Tests the `install.sh` script:
- Handles local directory source (for testing)
- Creates installation directory
- Creates symlink
- Provides next-step instructions

## Test Environment Variables

Tests use these environment variables to avoid interfering with your actual installation:

- `TANDEM_REPO_URL` - Where to clone from (defaults to local directory for tests)
- `TANDEM_INSTALL_DIR` - Where to install (defaults to test directory)

## CI/CD Integration

Add to your CI pipeline:

```yaml
# GitHub Actions
- name: Test Installation
  run: bash tests/run_all.sh

# GitLab CI
test:
  script:
    - bash tests/run_all.sh
```

## Adding New Tests

1. Create `tests/test_new_feature.sh`
2. Make it executable: `chmod +x tests/test_new_feature.sh`
3. Add to `tests/run_all.sh` in the `run_test` section
4. Follow the pattern: set -e, cleanup function, clear test name

Example:

```bash
#!/usr/bin/env bash
set -e

TEST_NAME="New Feature"
echo "🔴 TEST: $TEST_NAME"

cleanup() {
    # cleanup code
}

# Setup
# Test
# Assertions

cleanup
echo "✅ PASS: $TEST_NAME"
exit 0
```
