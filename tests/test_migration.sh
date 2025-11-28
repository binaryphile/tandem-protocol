#!/usr/bin/env bash
# Test: Migration script from MIGRATION.md works

set -e

TEST_NAME="Migration Script"
echo "🔴 TEST: $TEST_NAME"

# Test directory
TEST_DIR="/tmp/test-migration-$$"

cleanup() {
    rm -rf "$TEST_DIR"
}

# Cleanup before test
cleanup
mkdir -p "$TEST_DIR/project-a"
mkdir -p "$TEST_DIR/project-b"

echo "📍 Testing migration from env var to tilde path"

# Create test CLAUDE.md files with old syntax
cat > "$TEST_DIR/project-a/CLAUDE.md" <<'EOF'
# Test Project A
@$TANDEM_PROTOCOL_DIR/tandem-protocol.md
EOF

cat > "$TEST_DIR/project-b/CLAUDE.md" <<'EOF'
# Test Project B

Some other content

@$TANDEM_PROTOCOL_DIR/tandem-protocol.md

More content
EOF

# Run migration command from MIGRATION.md
echo "🔄 Running migration sed command..."
find "$TEST_DIR" -name "CLAUDE.md" -type f -exec \
  sed -i.bak 's|@\$TANDEM_PROTOCOL_DIR/tandem-protocol.md|@~/tandem-protocol/tandem-protocol.md|g' {} \;

# Assertions
echo "🔍 Verifying migration..."

# Check project-a
if ! grep -q "@~/tandem-protocol/tandem-protocol.md" "$TEST_DIR/project-a/CLAUDE.md"; then
    echo "❌ FAIL: project-a CLAUDE.md not updated correctly"
    cat "$TEST_DIR/project-a/CLAUDE.md"
    cleanup
    exit 1
fi

if grep -q '$TANDEM_PROTOCOL_DIR' "$TEST_DIR/project-a/CLAUDE.md"; then
    echo "❌ FAIL: project-a still contains env var reference"
    cat "$TEST_DIR/project-a/CLAUDE.md"
    cleanup
    exit 1
fi

# Check project-b
if ! grep -q "@~/tandem-protocol/tandem-protocol.md" "$TEST_DIR/project-b/CLAUDE.md"; then
    echo "❌ FAIL: project-b CLAUDE.md not updated correctly"
    cat "$TEST_DIR/project-b/CLAUDE.md"
    cleanup
    exit 1
fi

if grep -q '$TANDEM_PROTOCOL_DIR' "$TEST_DIR/project-b/CLAUDE.md"; then
    echo "❌ FAIL: project-b still contains env var reference"
    cat "$TEST_DIR/project-b/CLAUDE.md"
    cleanup
    exit 1
fi

# Check backup files created
if [ ! -f "$TEST_DIR/project-a/CLAUDE.md.bak" ]; then
    echo "❌ FAIL: Backup file not created for project-a"
    cleanup
    exit 1
fi

if [ ! -f "$TEST_DIR/project-b/CLAUDE.md.bak" ]; then
    echo "❌ FAIL: Backup file not created for project-b"
    cleanup
    exit 1
fi

# Cleanup
cleanup

echo "✅ PASS: $TEST_NAME"
exit 0
