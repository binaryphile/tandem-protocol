#!/bin/bash
# UC2 Plan Mode & File Distinction - Document Tests
# Tests verify README.md contains plan file guidance (PI model)

PROTOCOL="../README.md"
PASSED=0
FAILED=0

echo "=== UC2 Plan Mode & File Distinction Tests ==="
echo "Testing: $PROTOCOL"
echo ""

# T1: Plan file location mentioned
if grep -qiE '~/\.claude/plans|plans/' "$PROTOCOL"; then
    echo "PASS: T1 - Plan file location"
    ((PASSED++))
else
    echo "FAIL: T1 - Plan file location"
    echo "      Pattern not found: ~/.claude/plans"
    ((FAILED++))
fi

# T2: Plan file template exists
if grep -qiE 'Plan File Template' "$PROTOCOL"; then
    echo "PASS: T2 - Plan file template exists"
    ((PASSED++))
else
    echo "FAIL: T2 - Plan file template exists"
    echo "      Pattern not found: Plan File Template"
    ((FAILED++))
fi

# T3: Gate sections in template
if grep -qE 'At Gate [12]' "$PROTOCOL"; then
    echo "PASS: T3 - Gate sections in template"
    ((PASSED++))
else
    echo "FAIL: T3 - Gate sections in template"
    echo "      Pattern not found: At Gate N"
    ((FAILED++))
fi

# T4: Tasks JSON in template
if grep -qiE 'Tasks.*JSON|TaskCreate' "$PROTOCOL"; then
    echo "PASS: T4 - Tasks JSON in template"
    ((PASSED++))
else
    echo "FAIL: T4 - Tasks JSON in template"
    echo "      Pattern not found: Tasks JSON or TaskCreate"
    ((FAILED++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

exit $FAILED
