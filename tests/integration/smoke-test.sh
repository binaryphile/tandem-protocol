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
echo "Step 3: Test Era helpers..."

# Publish a test event to Era
era publish -s "$ERA_STREAM" --type contract 'phase = "smoke-test"

[[criteria]]
name = "infrastructure works"' 2>/dev/null

# Test Era query helpers
echo ""
echo "Step 4: Test assertions..."

assert_era_event_exists "Contract in Era" "contract"
assert_era_event_count "No Completion yet" "complete" 0 0
assert_era_event_count "Exactly 1 Contract" "contract" 1 1

echo ""
echo "Step 5: Test utilities..."

# Test get_era_payload
PAYLOAD=$(get_era_payload "contract")
if [[ -n "$PAYLOAD" ]]; then
    echo -e "${GREEN}PASS${NC}: get_era_payload works"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: get_era_payload returned empty"
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
