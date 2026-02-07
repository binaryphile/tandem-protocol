#!/bin/bash
# UC10 Plan File Compliance - Behavioral Tests
# Tests that protocol enforces explicit behavioral instructions in plan files

PROTOCOL="../README.md"

echo "=== UC10 Plan File Compliance Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Enforcement instruction near Gate 1 (not just template elsewhere)
# The requirement to include TaskAPI/logging must be AT the Gate 1 section
if grep -B5 -A10 -i "Gate 1" "$PROTOCOL" | grep -qiE '(MUST|require|verify).*([Tt]ask|log)'; then
    echo "PASS: T1 - Enforcement near Gate 1"
    ((PASS++))
else
    echo "FAIL: T1 - Enforcement near Gate 1"
    echo "      Expected: MUST/require/verify + task/log within Gate 1 context"
    ((FAIL++))
fi

# T2: Plan file template requires explicit TaskAPI calls
if grep -qiE '(TaskCreate|TaskUpdate)' "$PROTOCOL"; then
    echo "PASS: T2 - TaskAPI calls in template"
    ((PASS++))
else
    echo "FAIL: T2 - TaskAPI calls in template"
    echo "      Pattern not found: TaskCreate or TaskUpdate"
    ((FAIL++))
fi

# T3: Plan file template requires explicit logging calls
if grep -qiE '(Log Contract|Log Completion|Log Interaction|append.*log)' "$PROTOCOL"; then
    echo "PASS: T3 - Logging calls in template"
    ((PASS++))
else
    echo "FAIL: T3 - Logging calls in template"
    echo "      Pattern not found: Log Contract/Completion/Interaction"
    ((FAIL++))
fi

# T4: "At Gate" sections exist with behavioral instructions
if grep -qE 'At Gate [12].*Approval' "$PROTOCOL"; then
    echo "PASS: T4 - At Gate sections exist"
    ((PASS++))
else
    echo "FAIL: T4 - At Gate sections exist"
    echo "      Pattern not found: 'At Gate N Approval' sections"
    ((FAIL++))
fi

# T5: Verification checklist before requesting approval
if grep -B10 "May I proceed" "$PROTOCOL" | grep -qiE '(verify|checklist|\[ \])'; then
    echo "PASS: T5 - Verification before approval request"
    ((PASS++))
else
    echo "FAIL: T5 - Verification before approval request"
    echo "      Expected: verify/checklist near 'May I proceed'"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
