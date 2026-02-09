#!/bin/bash
# UC7 Event Logging - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc7-design.md

PROTOCOL="../README.md"

echo "=== UC7 Event Logging Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Contract entry format with checkboxes (from design doc)
if grep -qE 'Contract:.*\[ \]' "$PROTOCOL"; then
    echo "PASS: T1 - Contract entry with checkboxes"
    ((PASS++))
else
    echo "FAIL: T1 - Contract entry with checkboxes"
    echo "      Expected: Contract:.*[ ]"
    ((FAIL++))
fi

# T2: Completion entry format with filled checkboxes (from design doc)
if grep -qE 'Completion:.*\[x\]' "$PROTOCOL"; then
    echo "PASS: T2 - Completion entry with [x]"
    ((PASS++))
else
    echo "FAIL: T2 - Completion entry with [x]"
    echo "      Expected: Completion:.*[x]"
    ((FAIL++))
fi

# T3: Interaction entry format (from design doc)
if grep -qE 'Interaction:.*->' "$PROTOCOL"; then
    echo "PASS: T3 - Interaction entry with arrow"
    ((PASS++))
else
    echo "FAIL: T3 - Interaction entry with arrow"
    echo "      Expected: Interaction:.*->"
    ((FAIL++))
fi

# T4: No contract file references (from design doc - negative test)
if grep -qE 'phase-.*-contract\.md' "$PROTOCOL"; then
    echo "FAIL: T4 - No contract file references"
    echo "      Found deprecated: phase-*-contract.md"
    ((FAIL++))
else
    echo "PASS: T4 - No contract file references"
    ((PASS++))
fi

# T5: Completion copies Contract criteria verbatim (from design doc)
if grep -qiE 'copy.*[Cc]ontract.*criteria|criteria.*verbatim' "$PROTOCOL"; then
    echo "PASS: T5 - Completion copies criteria"
    ((PASS++))
else
    echo "FAIL: T5 - Completion copies criteria"
    echo "      Expected: copy.*Contract.*criteria or criteria.*verbatim"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
