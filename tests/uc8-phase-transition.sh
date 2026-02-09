#!/bin/bash
# UC8 Todo Integration - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc8-design.md

PROTOCOL="../README.md"

echo "=== UC8 Todo Integration Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Expand current phase in plan (from design doc)
if grep -qE '[Ee]xpand.*current.*phase|current.*phase.*expand' "$PROTOCOL"; then
    echo "PASS: T1 - Expand current phase"
    ((PASS++))
else
    echo "FAIL: T1 - Expand current phase"
    echo "      Expected: expand.*current.*phase or current.*phase.*expand"
    ((FAIL++))
fi

# T2: Collapse completed phase (from design doc)
if grep -qE '[Cc]ollapse.*completed|completed.*collapse' "$PROTOCOL"; then
    echo "PASS: T2 - Collapse completed phase"
    ((PASS++))
else
    echo "FAIL: T2 - Collapse completed phase"
    echo "      Expected: collapse.*completed or completed.*collapse"
    ((FAIL++))
fi

# T3: Plan file as todo source (from design doc)
if grep -qiE 'plan.*file.*todo|read.*todos.*plan|plan file.*source' "$PROTOCOL"; then
    echo "PASS: T3 - Plan file as todo source"
    ((PASS++))
else
    echo "FAIL: T3 - Plan file as todo source"
    echo "      Expected: plan.*file.*todo or plan file.*source"
    ((FAIL++))
fi

# T4: Future phases as skeletons (from use case success guarantee)
if grep -qiE 'skeleton|future.*phase' "$PROTOCOL"; then
    echo "PASS: T4 - Future phases as skeletons"
    ((PASS++))
else
    echo "FAIL: T4 - Future phases as skeletons"
    echo "      Expected: skeleton or future.*phase"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
