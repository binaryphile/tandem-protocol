#!/bin/bash
# UC4 Archive/Logging - Behavioral Tests
# Tests that README.md contains logging guidance (PI model)

PROTOCOL="../README.md"

echo "=== UC4 Archive/Logging Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Log to plan-log.md
if grep -qE 'plan-log\.md' "$PROTOCOL"; then
    echo "PASS: T1 - Log to plan-log.md"
    ((PASS++))
else
    echo "FAIL: T1 - Log to plan-log.md"
    echo "      Pattern not found: plan-log.md"
    ((FAIL++))
fi

# T2: Contract entry at Gate 1
if grep -qiE 'Contract.*Gate 1|Log Contract' "$PROTOCOL"; then
    echo "PASS: T2 - Contract entry at Gate 1"
    ((PASS++))
else
    echo "FAIL: T2 - Contract entry at Gate 1"
    echo "      Pattern not found: Contract at Gate 1"
    ((FAIL++))
fi

# T3: Completion entry at Gate 2
if grep -qiE 'Completion.*Gate 2|Log Completion' "$PROTOCOL"; then
    echo "PASS: T3 - Completion entry at Gate 2"
    ((PASS++))
else
    echo "FAIL: T3 - Completion entry at Gate 2"
    echo "      Pattern not found: Completion at Gate 2"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
