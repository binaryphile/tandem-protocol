#!/bin/bash
# UC3 Plan Mode Entry - Behavioral Tests
# Tests that README.md contains plan mode guidance (PI model)

PROTOCOL="../README.md"

echo "=== UC3 Plan Mode Entry Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Plan mode mentioned
if grep -qiE 'Plan Mode|plan mode' "$PROTOCOL"; then
    echo "PASS: T1 - Plan mode mentioned"
    ((PASS++))
else
    echo "FAIL: T1 - Plan mode mentioned"
    echo "      Pattern not found: Plan Mode"
    ((FAIL++))
fi

# T2: Explore/design in Plan stage
if grep -qiE 'Explore.*design|understand.*design' "$PROTOCOL"; then
    echo "PASS: T2 - Explore/design in Plan stage"
    ((PASS++))
else
    echo "FAIL: T2 - Explore/design in Plan stage"
    echo "      Pattern not found: Explore.*design"
    ((FAIL++))
fi

# T3: Ask questions mentioned
if grep -qiE 'ask.*question' "$PROTOCOL"; then
    echo "PASS: T3 - Ask questions mentioned"
    ((PASS++))
else
    echo "FAIL: T3 - Ask questions mentioned"
    echo "      Pattern not found: ask.*question"
    ((FAIL++))
fi

# T4: Gate 1 approval
if grep -qiE 'Gate 1.*approv|approve.*plan' "$PROTOCOL"; then
    echo "PASS: T4 - Gate 1 approval"
    ((PASS++))
else
    echo "FAIL: T4 - Gate 1 approval"
    echo "      Pattern not found: Gate 1 approval"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
