#!/bin/bash
# UC8 Todo Integration - Behavioral Tests
# Tests that README.md contains TaskAPI/telescoping guidance (PI model)

PROTOCOL="../README.md"

echo "=== UC8 Todo Integration Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: TaskCreate mentioned
if grep -qE 'TaskCreate' "$PROTOCOL"; then
    echo "PASS: T1 - TaskCreate mentioned"
    ((PASS++))
else
    echo "FAIL: T1 - TaskCreate mentioned"
    echo "      Pattern not found: TaskCreate"
    ((FAIL++))
fi

# T2: TaskUpdate mentioned
if grep -qE 'TaskUpdate' "$PROTOCOL"; then
    echo "PASS: T2 - TaskUpdate mentioned"
    ((PASS++))
else
    echo "FAIL: T2 - TaskUpdate mentioned"
    echo "      Pattern not found: TaskUpdate"
    ((FAIL++))
fi

# T3: Telescope mentioned
if grep -qiE '[Tt]elescop' "$PROTOCOL"; then
    echo "PASS: T3 - Telescope mentioned"
    ((PASS++))
else
    echo "FAIL: T3 - Telescope mentioned"
    echo "      Pattern not found: Telescope"
    ((FAIL++))
fi

# T4: Delete tasks at phase end
if grep -qiE 'delete.*task|delete.*phase' "$PROTOCOL"; then
    echo "PASS: T4 - Delete tasks"
    ((PASS++))
else
    echo "FAIL: T4 - Delete tasks"
    echo "      Pattern not found: delete.*task"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
