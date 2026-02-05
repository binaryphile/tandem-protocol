#!/bin/bash
# UC1 Step 1b Sequencing Rule - Behavioral Tests
# Tests verify tandem-protocol.md contains required guidance

PROTOCOL="../tandem-protocol.md"
PASSED=0
FAILED=0

# Test helper
test_grep() {
    local test_id="$1"
    local description="$2"
    local pattern="$3"

    if grep -qE "$pattern" "$PROTOCOL"; then
        echo "PASS: $test_id - $description"
        ((PASSED++))
    else
        echo "FAIL: $test_id - $description"
        echo "      Pattern not found: $pattern"
        ((FAILED++))
    fi
}

# Test helper for multi-pattern (both must match in Step 1b section)
test_grep_section() {
    local test_id="$1"
    local description="$2"
    local pattern1="$3"
    local pattern2="$4"

    # Extract Step 1b section (between "### Step 1b" and next "### Step")
    local section=$(sed -n '/### Step 1b/,/### Step 1c/p' "$PROTOCOL")

    if echo "$section" | grep -qE "$pattern1" && echo "$section" | grep -qE "$pattern2"; then
        echo "PASS: $test_id - $description"
        ((PASSED++))
    else
        echo "FAIL: $test_id - $description"
        echo "      Patterns not found in Step 1b section"
        ((FAILED++))
    fi
}

echo "=== UC1 Step 1b Sequencing Tests ==="
echo "Testing: $PROTOCOL"
echo ""

# T1: Explicit "ASKED not embedded" rule
test_grep "T1" "Explicit ASKED not embedded rule" \
    "(ASKED.*not.*embedded|embedded.*not.*ASKED|ASKED.*not.*plan file)"

# T2: AskUserQuestion tool integration
test_grep "T2" "AskUserQuestion tool integration" \
    "tool_available.*AskUserQuestion"

# T3: Fallback for no-tool case (both patterns in Step 1b)
test_grep_section "T3" "Fallback for no-tool case" \
    "else:" "present.*[Qq]uestions"

# T4: No-questions explicit statement
test_grep "T4" "No-questions explicit statement" \
    "([Nn]o.*clarifying.*questions|understanding.*complete)"

# T5: Anti-pattern guidance mentions TBD
test_grep "T5" "Anti-pattern: TBD mentioned" \
    "(TBD|to be determined|open question)"

# T6: Anti-pattern guidance mentions assuming
test_grep "T6" "Anti-pattern: assuming mentioned" \
    "assuming.*without"

# T7: Plan contains ANSWERS rule
test_grep "T7" "Plan contains ANSWERS rule" \
    "(ANSWERS.*not.*questions|answers.*not.*open|contain.*ANSWERS)"

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
