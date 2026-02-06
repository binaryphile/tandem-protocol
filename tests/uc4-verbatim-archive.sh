#!/bin/bash
# UC4 Verbatim Archive Rule - Document Tests
# Tests verify tandem-protocol.md contains verbatim archive guidance

PROTOCOL="../tandem-protocol.md"
PASSED=0
FAILED=0

test_section() {
    local test_id="$1"
    local description="$2"
    local pattern="$3"

    if grep -qiE "$pattern" "$PROTOCOL"; then
        echo "PASS: $test_id - $description"
        ((PASSED++))
    else
        echo "FAIL: $test_id - $description"
        echo "      Pattern not found: $pattern"
        ((FAILED++))
    fi
}

echo "=== UC4 Verbatim Archive Rule Tests ==="
echo "Testing: $PROTOCOL"
echo ""

# T1: Verbatim guidance near archive/cat commands
# Must be in Step 5b or Step 1e context, not just anywhere
ARCHIVE_SECTIONS=$(sed -n '/Step 5b\|Step 1e/,/^###\|^---/p' "$PROTOCOL")
if echo "$ARCHIVE_SECTIONS" | grep -qiE "VERBATIM|no summar"; then
    echo "PASS: T1 - Verbatim guidance at archive"
    ((PASSED++))
else
    echo "FAIL: T1 - Verbatim guidance at archive"
    echo "      Pattern not found in Step 1e or Step 5b sections"
    ((FAILED++))
fi
# Skip the generic test_section call for T1

# T2: cat command for archive (should already pass)
test_section "T2" "cat command for archive" \
    "cat.*plan-log|cat.*>>"

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
