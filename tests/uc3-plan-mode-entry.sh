#!/bin/bash
# UC3 Plan Mode Entry Sequence - Document Tests
# Tests verify README.md contains required guidance in Step 2

PROTOCOL="../README.md"
PASSED=0
FAILED=0

# Extract Step 2 section (everything before Step 2a)
STEP1=$(sed -n '/^## Step 2:/,/### Step 2a/p' "$PROTOCOL")

test_section() {
    local test_id="$1"
    local description="$2"
    local pattern="$3"

    if echo "$STEP1" | grep -qiE "$pattern"; then
        echo "PASS: $test_id - $description"
        ((PASSED++))
    else
        echo "FAIL: $test_id - $description"
        echo "      Pattern not found: $pattern"
        ((FAILED++))
    fi
}

echo "=== UC3 Plan Mode Entry Sequence Tests ==="
echo "Testing: $PROTOCOL (Step 2 section)"
echo ""

# T1: Quote verbatim guidance
test_section "T1" "Quote verbatim guidance" \
    "[Qq]uote.*verbatim|VERBATIM|no summar"

# T2: Analysis grade before plan grade
test_section "T2" "Analysis grade before plan grade" \
    "analysis.*FIRST|/a.*before|grade.*analysis.*grade.*plan"

# T3: BLOCKING wait for direction
test_section "T3" "BLOCKING wait for direction" \
    "BLOCKING.*wait|wait.*direction"

# T4: Improve path (addresses all deductions)
test_section "T4" "Improve path" \
    "improve.*ALL|ALL.*deductions|address.*deductions"

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
