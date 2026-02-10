#!/bin/bash
# Smoke Test - Quick verification that test infrastructure works
# Runs a minimal scenario to verify:
# 1. Session can start
# 2. Session can resume
# 3. Artifacts are created
# 4. Assertions work
#
# This does NOT test protocol compliance - just test infrastructure
#
# Run time: ~30 seconds
# Cost: ~$0.08 per run

source "$(dirname "$0")/common.sh"

print_header "Smoke Test"

# Setup
setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start session..."
RESULT=$(start_session "Say hello and confirm you can see CLAUDE.md" 2)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo -e "${RED}FAIL${NC}: Could not start session"
    echo "Result: $RESULT"
    exit 1
fi

echo -e "${GREEN}PASS${NC}: Session started ($SESSION_ID)"
((PASS++)) || true

# Check turns were tracked
if [[ $LAST_TURNS -gt 0 ]]; then
    echo -e "${GREEN}PASS${NC}: Turn tracking works ($LAST_TURNS turns)"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: Turn tracking returned 0"
fi

echo ""
echo "Step 2: Resume session..."
sleep 1
RESUME_RESULT=$(resume_session "What project are we in?" 2)

if [[ -n "$RESUME_RESULT" ]]; then
    echo -e "${GREEN}PASS${NC}: Session resumed"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: Could not resume session"
    ((FAIL++)) || true
fi

echo ""
echo "Step 3: Create test artifact..."
echo "2026-02-09T00:00:00Z | Contract: Smoke Test | [ ] infrastructure works" >> "$TEST_CWD/plan-log.md"

# Test assertions
echo ""
echo "Step 4: Test assertions..."

assert_exists "Contract in plan-log" "Contract:.*Smoke Test" "$TEST_CWD/plan-log.md"
assert_not_exists "No Completion yet" "Completion:" "$TEST_CWD/plan-log.md"
assert_count "Exactly 1 Contract" "Contract:" "$TEST_CWD/plan-log.md" 1 1

echo ""
echo "Step 5: Test utilities..."

# Test get_contracts
CONTRACTS=$(get_contracts)
if [[ -n "$CONTRACTS" ]]; then
    echo -e "${GREEN}PASS${NC}: get_contracts works"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: get_contracts returned empty"
    ((FAIL++)) || true
fi

# Summary
print_summary

echo ""
if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}SMOKE TEST PASSED${NC} - Test infrastructure is working"
    echo ""
    generate_report
    exit 0
else
    echo -e "${RED}SMOKE TEST FAILED${NC} - Check errors above"
    exit 1
fi
