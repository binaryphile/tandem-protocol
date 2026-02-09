#!/bin/bash
# UC6 Lesson Capture - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc6-design.md

PROTOCOL="../README.md"

echo "=== UC6 Lesson Capture Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Actionability test at grading (from design doc)
if grep -qE '[Aa]ctionab.*test|[Cc]an I fix this now' "$PROTOCOL"; then
    echo "PASS: T1 - Actionability test"
    ((PASS++))
else
    echo "FAIL: T1 - Actionability test"
    echo "      Expected: actionab.*test or Can I fix this now"
    ((FAIL++))
fi

# T2: Non-actionable → guide routing (from design doc)
if grep -qE 'guide.*not.*deduct|capture.*guide' "$PROTOCOL"; then
    echo "PASS: T2 - Guide routing (not deduct)"
    ((PASS++))
else
    echo "FAIL: T2 - Guide routing (not deduct)"
    echo "      Expected: guide.*not.*deduct or capture.*guide"
    ((FAIL++))
fi

# T3: No grade inflation (from use case success guarantee)
if grep -qiE 'not.*deduct|don.t.*deduct|no.*inflation' "$PROTOCOL"; then
    echo "PASS: T3 - No grade inflation"
    ((PASS++))
else
    echo "FAIL: T3 - No grade inflation"
    echo "      Expected: not.*deduct or don't.*deduct"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
