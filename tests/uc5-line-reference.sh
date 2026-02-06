#!/bin/bash
# UC5 Line Reference Guidance - Document Tests
# Tests verify tandem-protocol.md contains line reference verification guidance

PROTOCOL="../tandem-protocol.md"
PASSED=0
FAILED=0

echo "=== UC5 Line Reference Guidance Tests ==="
echo "Testing: $PROTOCOL"
echo ""

# T1: Line reference verification guidance in Step 3
STEP3=$(sed -n '/^## Step 3:/,/^## Step 4:/p' "$PROTOCOL")
if echo "$STEP3" | grep -qiE "verify.*line|line.*shift|numbers.*shift"; then
    echo "PASS: T1 - Line reference verification guidance"
    ((PASSED++))
else
    echo "FAIL: T1 - Line reference verification guidance"
    echo "      Pattern not found in Step 3 section"
    ((FAILED++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
