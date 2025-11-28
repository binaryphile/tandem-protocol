#!/usr/bin/env bash
# Test: All URLs in documentation are valid (no placeholders)

set -e

TEST_NAME="URL Validation"
echo "🔴 TEST: $TEST_NAME"

# Get source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📍 Testing URLs in documentation files"

FAILED=0

# Check README.md
echo "🔍 Checking README.md..."
if grep -n "USER" "$SCRIPT_DIR/README.md" 2>/dev/null | grep -v "^Binary"; then
    echo "❌ FAIL: README.md contains USER placeholder"
    FAILED=1
fi

# Check install.sh
echo "🔍 Checking install.sh..."
if grep -n "github.com/USER" "$SCRIPT_DIR/install.sh" 2>/dev/null; then
    echo "❌ FAIL: install.sh contains USER placeholder in GitHub URL"
    FAILED=1
fi

# Check ADVANCED.md
echo "🔍 Checking ADVANCED.md..."
if grep -n "github.com/USER" "$SCRIPT_DIR/ADVANCED.md" 2>/dev/null; then
    echo "❌ FAIL: ADVANCED.md contains USER placeholder in GitHub URL"
    FAILED=1
fi

# Check MIGRATION.md
echo "🔍 Checking MIGRATION.md..."
if grep -n "github.com/USER" "$SCRIPT_DIR/MIGRATION.md" 2>/dev/null; then
    echo "❌ FAIL: MIGRATION.md contains USER placeholder in GitHub URL"
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "❌ FAIL: Found placeholder URLs - need to replace USER with actual org/username"
    exit 1
fi

echo "✅ PASS: $TEST_NAME - No placeholder URLs found"
exit 0
