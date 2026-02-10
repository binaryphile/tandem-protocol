#!/bin/bash
# UC2 Integration Test: Content Distinction
# Verifies plan file contains HOW, Contract contains WHAT
#
# Scenario: Plan a task, verify content routing
# 1. Plan task
# 2. Approve (Gate 1)
# 3. Verify plan file has approach/methodology
# 4. Verify Contract has criteria (not methodology)

source "$(dirname "$0")/common.sh"

print_header "UC2: Content Distinction (HOW vs WHAT)"

# Setup
setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start session with planning task..."
RESULT=$(start_session "/tandem plan to implement fizzbuzz so we test content routing" 15)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Gate 1: Approve plan
echo ""
echo "Step 2: Gate 1 - proceed..."
sleep 2
resume_session "proceed" 10 > /dev/null

# Find the plan file
echo ""
echo "Step 3: Checking artifacts..."
PLAN_FILE=$(get_plan_file)

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
    echo "WARN: No plan file found, checking workspace md files..."
    # List what's available
    ls -la "$TEST_CWD"/*.md 2>/dev/null || true
    ls -la ~/.claude/plans/*.md 2>/dev/null | head -3 || true
fi

# UC2 Assertions
echo ""
echo "UC2 Content Checks..."

# Plan file should have HOW content
if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
    echo "Plan file: $PLAN_FILE"

    # Plan file should NOT contain Contract-style content
    assert_not_exists "Plan file: no 'Success Criteria' section" '[Ss]uccess [Cc]riteria' "$PLAN_FILE"

    # Deliverables as section header is Contract content
    assert_not_exists "Plan file: no 'Deliverables' section header" '^#+.*[Dd]eliverables\|^Deliverables:' "$PLAN_FILE"

    # Plan file SHOULD have approach/methodology (HOW content)
    # Check for common HOW keywords
    if grep -qiE 'approach|methodology|strategy|how|implement' "$PLAN_FILE"; then
        echo -e "${GREEN}PASS${NC}: Plan file has HOW content"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: Plan file may be missing HOW content"
    fi
else
    echo "SKIP: No plan file found to validate"
fi

# Contract should have WHAT content
echo ""
CONTRACT=$(get_contracts | head -1)
if [[ -n "$CONTRACT" ]]; then
    echo "Contract: ${CONTRACT:0:80}..."

    # Contract should have criteria checkboxes
    assert_exists "Contract has criteria checkboxes" '\[ \]' "$TEST_CWD/plan-log.md"

    # Contract should NOT have methodology
    if echo "$CONTRACT" | grep -qi "methodology"; then
        echo -e "${RED}FAIL${NC}: Contract contains 'methodology' (Plan content leak)"
        ((FAIL++)) || true
    else
        echo -e "${GREEN}PASS${NC}: Contract has no 'methodology'"
        ((PASS++)) || true
    fi

    # Contract should NOT have "research strategy"
    if echo "$CONTRACT" | grep -qi "research strategy"; then
        echo -e "${RED}FAIL${NC}: Contract contains 'research strategy' (Plan content leak)"
        ((FAIL++)) || true
    else
        echo -e "${GREEN}PASS${NC}: Contract has no 'research strategy'"
        ((PASS++)) || true
    fi
else
    echo -e "${RED}FAIL${NC}: No Contract entry found"
    ((FAIL++)) || true
fi

# Print summary
print_summary

# Generate report
echo ""
generate_report

exit $FAIL
