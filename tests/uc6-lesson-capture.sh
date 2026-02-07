#!/bin/bash
# UC6 Lesson Capture - Behavioral Tests
# Tests that README.md contains lesson routing guidance (PI model)

PROTOCOL="../README.md"

echo "=== UC6 Lesson Capture Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Lesson capture mentioned
if grep -qiE 'lesson|Route.*guide' "$PROTOCOL"; then
    echo "PASS: T1 - Lessons mentioned"
    ((PASS++))
else
    echo "FAIL: T1 - Lessons mentioned"
    echo "      Pattern not found: lesson or Route.*guide"
    ((FAIL++))
fi

# T2: Guides in plan file template
if grep -qiE 'Route lessons to guides' "$PROTOCOL"; then
    echo "PASS: T2 - Route lessons in template"
    ((PASS++))
else
    echo "FAIL: T2 - Route lessons in template"
    echo "      Pattern not found: Route lessons to guides"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
