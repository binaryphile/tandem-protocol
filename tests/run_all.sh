#!/usr/bin/env bash
# Tandem Protocol Test Suite Runner

set -e

echo "╔════════════════════════════════════════════════╗"
echo "║   Tandem Protocol Test Suite                  ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Get test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASSED=0
FAILED=0
TESTS=()

# Run a test and track results
run_test() {
    local test_script="$1"
    local test_name=$(basename "$test_script" .sh)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if bash "$test_script"; then
        PASSED=$((PASSED + 1))
        TESTS+=("✅ $test_name")
    else
        FAILED=$((FAILED + 1))
        TESTS+=("❌ $test_name")
    fi
}

# Run all tests
run_test "$TEST_DIR/test_urls.sh"
run_test "$TEST_DIR/test_migration.sh"
run_test "$TEST_DIR/test_manual_install.sh"
run_test "$TEST_DIR/test_quick_install.sh"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║   Test Results                                 ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

for test in "${TESTS[@]}"; do
    echo "  $test"
done

echo ""
echo "─────────────────────────────────────────────────"
echo "  PASSED: $PASSED"
echo "  FAILED: $FAILED"
echo "  TOTAL:  $((PASSED + FAILED))"
echo "─────────────────────────────────────────────────"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ ALL TESTS PASSED"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    exit 1
fi
