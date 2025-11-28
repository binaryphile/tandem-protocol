#!/usr/bin/env bash
# Test: Quick install from README works

set -e

TEST_NAME="Quick Install"
echo "🔴 TEST: $TEST_NAME"

# Clean slate
TEST_DIR="$HOME/tandem-protocol-test"
TEST_SYMLINK="$HOME/.claude/commands/tandem-test.md"

cleanup() {
    rm -rf "$TEST_DIR"
    rm -f "$TEST_SYMLINK"
}

# Cleanup before test
cleanup

# Get the install script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

echo "📍 Testing install script: $INSTALL_SCRIPT"

# Test that script exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "❌ FAIL: install.sh not found at $INSTALL_SCRIPT"
    exit 1
fi

# Set environment to use test directory
export TANDEM_REPO_URL="$SCRIPT_DIR"
export TANDEM_INSTALL_DIR="$TEST_DIR"

# Run the install script
bash "$INSTALL_SCRIPT" <<< "n" || {
    echo "❌ FAIL: install.sh failed to execute"
    cleanup
    exit 1
}

# Assertions
echo "🔍 Verifying installation..."

if [ ! -d "$TEST_DIR" ]; then
    echo "❌ FAIL: Installation directory not created: $TEST_DIR"
    cleanup
    exit 1
fi

if [ ! -f "$TEST_DIR/tandem-protocol.md" ]; then
    echo "❌ FAIL: tandem-protocol.md not found in $TEST_DIR"
    cleanup
    exit 1
fi

if [ ! -L "$HOME/.claude/commands/tandem.md" ]; then
    echo "❌ FAIL: Symlink not created at ~/.claude/commands/tandem.md"
    cleanup
    exit 1
fi

# Cleanup
cleanup

echo "✅ PASS: $TEST_NAME"
exit 0
