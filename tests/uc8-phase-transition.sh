#!/bin/bash
# UC8 Todo Integration with Plan File - Behavioral Tests
# Tests that tandem-protocol.md contains plan/todo integration guidance

PROTOCOL="../tandem-protocol.md"

echo "=== UC8 Todo Integration Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Expand current phase in plan
if grep -qiE '([Ee]xpand.*current.*phase|current.*phase.*expand|expand.*phase.*plan)' "$PROTOCOL"; then
    echo "PASS: T1 - Expand current phase in plan"
    ((PASS++))
else
    echo "FAIL: T1 - Expand current phase in plan"
    echo "      Pattern not found: (expand.*current.*phase)"
    ((FAIL++))
fi

# T2: Collapse completed phase
if grep -qiE '([Cc]ollapse.*completed|completed.*collapse|mark.*phase.*complete.*collapse)' "$PROTOCOL"; then
    echo "PASS: T2 - Collapse completed phase"
    ((PASS++))
else
    echo "FAIL: T2 - Collapse completed phase"
    echo "      Pattern not found: (collapse.*completed)"
    ((FAIL++))
fi

# T3: Plan file as todo source
if grep -qiE '(plan.*file.*todo|read.*todos.*plan|plan.*todo.*state|sync.*TodoWrite)' "$PROTOCOL"; then
    echo "PASS: T3 - Plan file as todo source"
    ((PASS++))
else
    echo "FAIL: T3 - Plan file as todo source"
    echo "      Pattern not found: (plan.*file.*todo|read.*todos.*plan)"
    ((FAIL++))
fi

# T4: Todo telescoping guidance (from original)
if grep -qiE '([Tt]elescope.*todo|delete.*completed.*task)' "$PROTOCOL"; then
    echo "PASS: T4 - Todo telescoping guidance"
    ((PASS++))
else
    echo "FAIL: T4 - Todo telescoping guidance"
    echo "      Pattern not found: (telescope.*todo)"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
