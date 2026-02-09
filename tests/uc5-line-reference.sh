#!/bin/bash
# UC5 Line Reference Guidance - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc5-design.md

PROTOCOL="../README.md"

echo "=== UC5 Line Reference Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Line reference verification guidance (from design doc)
if grep -qE 'verify.*line|line.*shift|numbers.*shift' "$PROTOCOL"; then
    echo "PASS: T1 - Line reference verification"
    ((PASS++))
else
    echo "FAIL: T1 - Line reference verification"
    echo "      Expected: verify.*line or line.*shift or numbers.*shift"
    ((FAIL++))
fi

# T2: Stale references updated (from use case success guarantee)
if grep -qiE 'update.*stale|verify.*before.*present|check.*after.*edit' "$PROTOCOL"; then
    echo "PASS: T2 - Update stale references"
    ((PASS++))
else
    echo "FAIL: T2 - Update stale references"
    echo "      Expected: update.*stale or verify.*before.*present"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
