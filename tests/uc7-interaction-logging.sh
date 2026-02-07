#!/bin/bash
# UC7 Event Logging - Behavioral Tests
# Tests that README.md contains event logging patterns (PI model)

PROTOCOL="../README.md"

echo "=== UC7 Event Logging Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Contract entry documented
if grep -qiE 'Contract.*Gate 1|Log Contract' "$PROTOCOL"; then
    echo "PASS: T1 - Contract entry documented"
    ((PASS++))
else
    echo "FAIL: T1 - Contract entry documented"
    echo "      Pattern not found: Contract at Gate 1"
    ((FAIL++))
fi

# T2: Completion entry documented
if grep -qiE 'Completion.*Gate 2|Log Completion' "$PROTOCOL"; then
    echo "PASS: T2 - Completion entry documented"
    ((PASS++))
else
    echo "FAIL: T2 - Completion entry documented"
    echo "      Pattern not found: Completion at Gate 2"
    ((FAIL++))
fi

# T3: Interaction entry documented
if grep -qiE 'Interaction.*grade|Interaction.*improve' "$PROTOCOL"; then
    echo "PASS: T3 - Interaction entry documented"
    ((PASS++))
else
    echo "FAIL: T3 - Interaction entry documented"
    echo "      Pattern not found: Interaction grade/improve"
    ((FAIL++))
fi

# T4: Timestamp format documented
if grep -qE 'TIMESTAMP' "$PROTOCOL"; then
    echo "PASS: T4 - Timestamp format documented"
    ((PASS++))
else
    echo "FAIL: T4 - Timestamp format documented"
    echo "      Pattern not found: TIMESTAMP"
    ((FAIL++))
fi

# T5: plan-log.md as target
if grep -qE 'plan-log\.md' "$PROTOCOL"; then
    echo "PASS: T5 - plan-log.md as target"
    ((PASS++))
else
    echo "FAIL: T5 - plan-log.md as target"
    echo "      Pattern not found: plan-log.md"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
