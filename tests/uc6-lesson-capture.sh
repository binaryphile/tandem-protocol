#!/bin/bash
# UC6 Lesson Capture - Behavioral Tests
# Tests that protocol contains explicit lesson triggers matching UC7/UC8 pattern

PROTOCOL="../README.md"
UC6_DOC="../docs/uc6-lesson-capture.md"

echo "=== UC6 Lesson Capture Tests ==="
echo "Testing: $PROTOCOL and $UC6_DOC"
echo ""

PASS=0
FAIL=0

# T1: Lesson entry in README Event Logging table
if grep -qE 'Lesson.*\|.*Non-actionable.*gap' "$PROTOCOL"; then
    echo "PASS: T1 - Lesson entry in Event Logging table"
    ((PASS++))
else
    echo "FAIL: T1 - Lesson entry in Event Logging table"
    echo "      Pattern not found: Lesson.*Non-actionable.*gap"
    ((FAIL++))
fi

# T2: Lesson format with arrow to guide
if grep -qE 'Lesson:.*->.*guide' "$PROTOCOL"; then
    echo "PASS: T2 - Lesson format with arrow to guide"
    ((PASS++))
else
    echo "FAIL: T2 - Lesson format with arrow to guide"
    echo "      Pattern not found: Lesson:.*->.*guide"
    ((FAIL++))
fi

# T3: UC6 has Entry Format table
if grep -qE 'Lesson Entry Format|Type.*When.*Format' "$UC6_DOC"; then
    echo "PASS: T3 - UC6 has Entry Format section"
    ((PASS++))
else
    echo "FAIL: T3 - UC6 has Entry Format section"
    echo "      Pattern not found: Lesson Entry Format or Type.*When.*Format"
    ((FAIL++))
fi

# T4: UC6 has Integration Points with Gate 2
if grep -qE 'Gate 2.*Lesson|Lesson.*Gate 2' "$UC6_DOC"; then
    echo "PASS: T4 - UC6 Integration Points includes Gate 2"
    ((PASS++))
else
    echo "FAIL: T4 - UC6 Integration Points includes Gate 2"
    echo "      Pattern not found: Gate 2.*Lesson"
    ((FAIL++))
fi

# T5: UC6 has locality instruction
if grep -qiE 'Locality.*plan file|plan file.*lesson.*instruction' "$UC6_DOC"; then
    echo "PASS: T5 - UC6 has locality instruction"
    ((PASS++))
else
    echo "FAIL: T5 - UC6 has locality instruction"
    echo "      Pattern not found: Locality.*plan file"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
