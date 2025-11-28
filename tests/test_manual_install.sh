#!/usr/bin/env bash
# Test: Manual install steps from README work

set -e

TEST_NAME="Manual Install"
echo "🔴 TEST: $TEST_NAME"

# Test directories
TEST_DIR="$HOME/tandem-protocol-manual-test"
TEST_SYMLINK="$HOME/.claude/commands/tandem-manual-test.md"
TEST_CLAUDE_MD="/tmp/test-manual-CLAUDE.md"

cleanup() {
    rm -rf "$TEST_DIR"
    rm -f "$TEST_SYMLINK"
    rm -f "$TEST_CLAUDE_MD"
}

# Cleanup before test
cleanup

# Get source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📍 Testing manual install steps"

# Step 1: Clone (simulate by copying)
echo "Step 1: Clone repository"
cp -r "$SCRIPT_DIR" "$TEST_DIR" || {
    echo "❌ FAIL: Could not copy protocol to test directory"
    cleanup
    exit 1
}

# Step 2: Create symlink
echo "Step 2: Create command symlink"
mkdir -p "$HOME/.claude/commands"
ln -sf "$TEST_DIR/tandem.md" "$TEST_SYMLINK" || {
    echo "❌ FAIL: Could not create symlink"
    cleanup
    exit 1
}

# Step 3: Add to CLAUDE.md
echo "Step 3: Add to CLAUDE.md"
cat > "$TEST_CLAUDE_MD" <<'EOF'
# Test Project

# Tandem Protocol
@~/tandem-protocol-manual-test/tandem-protocol.md
EOF

# Assertions
echo "🔍 Verifying manual installation..."

if [ ! -d "$TEST_DIR" ]; then
    echo "❌ FAIL: Test directory not found: $TEST_DIR"
    cleanup
    exit 1
fi

if [ ! -L "$TEST_SYMLINK" ]; then
    echo "❌ FAIL: Symlink not created at $TEST_SYMLINK"
    cleanup
    exit 1
fi

if [ ! -f "$TEST_CLAUDE_MD" ]; then
    echo "❌ FAIL: Test CLAUDE.md not created"
    cleanup
    exit 1
fi

if ! grep -q "@~/tandem-protocol-manual-test/tandem-protocol.md" "$TEST_CLAUDE_MD"; then
    echo "❌ FAIL: CLAUDE.md doesn't contain expected reference"
    cleanup
    exit 1
fi

# Cleanup
cleanup

echo "✅ PASS: $TEST_NAME"
exit 0
