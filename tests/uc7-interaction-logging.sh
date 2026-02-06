#!/bin/bash
# UC7 Interaction Logging - Behavioral Tests
# Tests that tandem-protocol.md contains interaction logging guidance

PROTOCOL="../tandem-protocol.md"

echo "=== UC7 Interaction Logging Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Interactions section in contract template
if grep -qiE '(### Interactions|Interaction.*log|interaction.*section)' "$PROTOCOL"; then
    echo "PASS: T1 - Interactions section in contract template"
    ((PASS++))
else
    echo "FAIL: T1 - Interactions section in contract template"
    echo "      Pattern not found: (### Interactions|Interaction.*log)"
    ((FAIL++))
fi

# T2: Table format for logging
if grep -qE 'Action.*Response.*Outcome' "$PROTOCOL"; then
    echo "PASS: T2 - Table format for logging"
    ((PASS++))
else
    echo "FAIL: T2 - Table format for logging"
    echo "      Pattern not found: Action.*Response.*Outcome"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
