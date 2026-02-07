#!/bin/bash
# UC5 Evidence/Verification - Behavioral Tests
# Tests that README.md contains evidence guidance (PI model)

PROTOCOL="../README.md"

echo "=== UC5 Evidence Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Evidence in completion
if grep -qiE 'evidence|criterion.*evidence' "$PROTOCOL"; then
    echo "PASS: T1 - Evidence mentioned"
    ((PASS++))
else
    echo "FAIL: T1 - Evidence mentioned"
    echo "      Pattern not found: evidence"
    ((FAIL++))
fi

# T2: Success criteria mentioned
if grep -qiE 'Success Criteria|criterion' "$PROTOCOL"; then
    echo "PASS: T2 - Success criteria mentioned"
    ((PASS++))
else
    echo "FAIL: T2 - Success criteria mentioned"
    echo "      Pattern not found: Success Criteria"
    ((FAIL++))
fi

# T3: Verification section in template
if grep -qiE 'Verification' "$PROTOCOL"; then
    echo "PASS: T3 - Verification section"
    ((PASS++))
else
    echo "FAIL: T3 - Verification section"
    echo "      Pattern not found: Verification"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
