#!/bin/bash
# UC6 Lesson Capture from Grading - Behavioral Tests
# Tests that README.md contains lesson capture guidance

PROTOCOL="../README.md"

echo "=== UC6 Lesson Capture Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Actionability test at grading
if grep -qiE '([Aa]ctionab.*test|[Cc]an I fix this now)' "$PROTOCOL"; then
    echo "PASS: T1 - Actionability test at grading"
    ((PASS++))
else
    echo "FAIL: T1 - Actionability test at grading"
    echo "      Pattern not found: (actionab.*test|Can I fix this now)"
    ((FAIL++))
fi

# T2: Non-actionable → guide routing
if grep -qiE '(guide.*not.*deduct|capture.*guide|NO.*guide)' "$PROTOCOL"; then
    echo "PASS: T2 - Non-actionable items routed to guide"
    ((PASS++))
else
    echo "FAIL: T2 - Non-actionable items routed to guide"
    echo "      Pattern not found: (guide.*not.*deduct|capture.*guide|NO.*guide)"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
