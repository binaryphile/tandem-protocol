#!/bin/bash
# UC2 Plan Mode & Content Distinction - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc2-design.md

PROTOCOL="../README.md"
PASSED=0
FAILED=0

echo "=== UC2 Plan Mode & File Distinction Tests ==="
echo "Testing: $PROTOCOL"
echo ""

# T1: Plan file = HOW (from design doc)
if grep -qE '[Pp]lan file.*HOW|HOW.*plan' "$PROTOCOL"; then
    echo "PASS: T1 - Plan file = HOW"
    ((PASSED++))
else
    echo "FAIL: T1 - Plan file = HOW"
    echo "      Expected: plan file.*HOW or HOW.*plan"
    ((FAILED++))
fi

# T2: Contract entry = WHAT (from design doc)
if grep -qE '[Cc]ontract.*WHAT|WHAT.*[Cc]ontract' "$PROTOCOL"; then
    echo "PASS: T2 - Contract entry = WHAT"
    ((PASSED++))
else
    echo "FAIL: T2 - Contract entry = WHAT"
    echo "      Expected: Contract.*WHAT or WHAT.*Contract"
    ((FAILED++))
fi

# T3: Plan file location (from design doc)
if grep -qE '~/.claude/plans/|plans/' "$PROTOCOL"; then
    echo "PASS: T3 - Plan file location"
    ((PASSED++))
else
    echo "FAIL: T3 - Plan file location"
    echo "      Expected: ~/.claude/plans/ or plans/"
    ((FAILED++))
fi

# T4: Plan persists across phases (from design doc)
if grep -qiE 'persist.*phase|across.*phase' "$PROTOCOL"; then
    echo "PASS: T4 - Plan persists across phases"
    ((PASSED++))
else
    echo "FAIL: T4 - Plan persists across phases"
    echo "      Expected: persist.*phase or across.*phase"
    ((FAILED++))
fi

# T5: Plan mode entered at start/before (from use case success guarantee)
if grep -qiE 'enter.*plan.*mode.*start|plan.*mode.*at.*start|start.*plan.*mode' "$PROTOCOL"; then
    echo "PASS: T5 - Plan mode entry timing"
    ((PASSED++))
else
    echo "FAIL: T5 - Plan mode entry timing"
    echo "      Expected: enter.*plan.*mode.*start or at.*start"
    ((FAILED++))
fi

# T6: Plan mode exited at Step 1c (from use case success guarantee)
if grep -qiE 'exit.*plan.*mode|ExitPlanMode' "$PROTOCOL"; then
    echo "PASS: T6 - Plan mode exit"
    ((PASSED++))
else
    echo "FAIL: T6 - Plan mode exit"
    echo "      Expected: exit.*plan.*mode or ExitPlanMode"
    ((FAILED++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

exit $FAILED
