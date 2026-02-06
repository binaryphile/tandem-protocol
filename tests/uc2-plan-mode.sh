#!/bin/bash
# UC2 Plan Mode & File Distinction - Document Tests
# Tests verify tandem-protocol.md contains required guidance in Step 2c

PROTOCOL="../tandem-protocol.md"
PASSED=0
FAILED=0

# Extract Step 2c section
STEP1C=$(sed -n '/### Step 2c/,/### Step 2d/p' "$PROTOCOL")

test_section() {
    local test_id="$1"
    local description="$2"
    local pattern="$3"

    if echo "$STEP1C" | grep -qiE "$pattern"; then
        echo "PASS: $test_id - $description"
        ((PASSED++))
    else
        echo "FAIL: $test_id - $description"
        echo "      Pattern not found: $pattern"
        ((FAILED++))
    fi
}

echo "=== UC2 Plan Mode & File Distinction Tests ==="
echo "Testing: $PROTOCOL (Step 2c section)"
echo ""

# T1: Plan file = HOW
test_section "T1" "Plan file = HOW" \
    "[Pp]lan.*file.*HOW|HOW.*approach|HOW.*methodology"

# T2: Contract file = WHAT
test_section "T2" "Contract file = WHAT" \
    "[Cc]ontract.*WHAT|WHAT.*scope|WHAT.*deliverables"

# T3: Plan file location mentioned
test_section "T3" "Plan file location" \
    "plans/|~/.claude"

# T4: Plan persists across phases
test_section "T4" "Plan persists across phases" \
    "persist|across.*phase|per-phase"

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
