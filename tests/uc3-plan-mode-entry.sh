#!/bin/bash
# UC3 Plan Mode Entry - Design Doc Tests
# Tests verify README.md contains patterns specified in docs/uc3-design.md

PROTOCOL="../README.md"

echo "=== UC3 Plan Mode Entry Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Quote verbatim guidance (from design doc)
if grep -qE '[Qq]uote.*verbatim|VERBATIM|no summar' "$PROTOCOL"; then
    echo "PASS: T1 - Quote verbatim guidance"
    ((PASS++))
else
    echo "FAIL: T1 - Quote verbatim guidance"
    echo "      Expected: quote.*verbatim or VERBATIM or no summar"
    ((FAIL++))
fi

# T2: Analysis grade before plan grade (from design doc)
if grep -qE 'analysis.*FIRST|/a.*before|grade.*analysis.*grade.*plan' "$PROTOCOL"; then
    echo "PASS: T2 - Analysis grade FIRST"
    ((PASS++))
else
    echo "FAIL: T2 - Analysis grade FIRST"
    echo "      Expected: analysis.*FIRST or /a.*before"
    ((FAIL++))
fi

# T3: BLOCKING wait for direction (from design doc)
if grep -qE 'BLOCKING.*wait|wait.*direction' "$PROTOCOL"; then
    echo "PASS: T3 - BLOCKING wait for direction"
    ((PASS++))
else
    echo "FAIL: T3 - BLOCKING wait for direction"
    echo "      Expected: BLOCKING.*wait or wait.*direction"
    ((FAIL++))
fi

# T4: Improve path addresses ALL deductions (from design doc)
if grep -qE 'improve.*ALL|ALL.*deductions|address.*deductions' "$PROTOCOL"; then
    echo "PASS: T4 - Improve ALL deductions"
    ((PASS++))
else
    echo "FAIL: T4 - Improve ALL deductions"
    echo "      Expected: improve.*ALL or ALL.*deductions"
    ((FAIL++))
fi

# T5: Plan grade provided (from use case success guarantee)
if grep -qiE 'grade.*plan.*quality|plan.*quality|Is this sound' "$PROTOCOL"; then
    echo "PASS: T5 - Plan grade provided"
    ((PASS++))
else
    echo "FAIL: T5 - Plan grade provided"
    echo "      Expected: grade.*plan.*quality or Is this sound"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
