#!/bin/bash
# UC7 Event Logging - Behavioral Tests
# Tests that tandem-protocol.md contains direct-to-log event patterns

PROTOCOL="../tandem-protocol.md"

echo "=== UC7 Event Logging Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Contract entry format documented
if grep -qE 'Contract:.*scope|Contract:.*deliverable|Contract:.*Phase' "$PROTOCOL"; then
    echo "PASS: T1 - Contract entry format documented"
    ((PASS++))
else
    echo "FAIL: T1 - Contract entry format documented"
    echo "      Pattern not found: Contract:.*scope|deliverable|Phase"
    ((FAIL++))
fi

# T2: Completion entry format documented
if grep -qE 'Completion:.*Step|Completion:.*complete' "$PROTOCOL"; then
    echo "PASS: T2 - Completion entry format documented"
    ((PASS++))
else
    echo "FAIL: T2 - Completion entry format documented"
    echo "      Pattern not found: Completion:.*Step"
    ((FAIL++))
fi

# T3: Interaction entry format documented
if grep -qE 'Interaction:.*→' "$PROTOCOL"; then
    echo "PASS: T3 - Interaction entry format documented"
    ((PASS++))
else
    echo "FAIL: T3 - Interaction entry format documented"
    echo "      Pattern not found: Interaction:.*→"
    ((FAIL++))
fi

# T4: No contract file references (should use direct logging)
if grep -qE 'phase-[0-9]+-contract\.md' "$PROTOCOL"; then
    echo "FAIL: T4 - Should not reference contract files (use direct logging)"
    echo "      Found: phase-N-contract.md reference"
    ((FAIL++))
else
    echo "PASS: T4 - No contract file references (uses direct logging)"
    ((PASS++))
fi

# T5: Timestamp format documented
if grep -qE 'YYYY-MM-DDTHH:MM:SSZ.*\|' "$PROTOCOL"; then
    echo "PASS: T5 - Timestamp format documented"
    ((PASS++))
else
    echo "FAIL: T5 - Timestamp format documented"
    echo "      Pattern not found: YYYY-MM-DDTHH:MM:SSZ | ..."
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
