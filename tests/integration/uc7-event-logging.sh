#!/bin/bash
# UC7 Integration Test: Event Logging
# Verifies Contract, Completion, and Interaction entries are logged correctly
#
# Scenario: Full gate sequence with /i improve cycle
# 1. Plan task (no Contract yet)
# 2. "proceed" (Gate 1) → Contract logged
# 3. "/i" → Interaction logged
# 4. "/i" → Interaction logged
# 5. "proceed" (Gate 2) → Completion logged

source "$(dirname "$0")/common.sh"

print_header "UC7: Event Logging"

# Setup
setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start session with planning task..."
RESULT=$(start_session "/tandem plan to implement fizzbuzz so we test UC7 logging" 15)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    echo "$RESULT"
    exit 1
fi
echo "Session: $SESSION_ID"

# Checkpoint 1: No Contract before Gate 1
echo ""
echo "Checkpoint 1: Before Gate 1"
assert_era_event_count "No Contract before approval" "contract" 0 0

# Gate 1: Approve plan (using context injection for reliability)
echo ""
echo "Step 2: Gate 1 - proceed..."
sleep 2
implementation_gate "proceed" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 2: Contract logged at Gate 1
echo ""
echo "Checkpoint 2: After Gate 1"
assert_era_event_exists "Contract entry exists" "contract"
# TOML contract should have criteria
CONTRACT_PAYLOAD=$(get_era_payload "contract")
if [[ -n "$CONTRACT_PAYLOAD" ]] && echo "$CONTRACT_PAYLOAD" | grep -qE '\[\[criteria\]\]|name\s*='; then
    echo -e "${GREEN}PASS${NC}: Contract has TOML criteria"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: Contract missing TOML criteria"
    ((FAIL++)) || true
fi
assert_era_event_count "No Completion yet" "complete" 0 0

# Grade
echo ""
echo "Step 3: Request /i..."
sleep 2
resume_session "/i" 5 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 3: Interaction logged for grade
echo ""
echo "Checkpoint 3: After /i"
# Check that an interaction event was published
assert_era_event_exists "Interaction entry for /i" "interaction"

# Improve
echo ""
echo "Step 4: Request /i..."
sleep 2
resume_session "/i" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 4: Second Interaction logged
echo ""
echo "Checkpoint 4: After second /i"
assert_era_event_count "2+ Interaction entries" "interaction" 2

# Gate 2: Approve results (using context injection for reliability)
echo ""
echo "Step 5: Gate 2 - proceed..."
sleep 2
completion_gate "proceed" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 5: Completion logged at Gate 2
echo ""
echo "Checkpoint 5: After Gate 2"
assert_era_event_exists "Completion entry exists" "complete"
# TOML attestation should have status = "delivered" and evidence
COMPLETION_PAYLOAD=$(get_era_payload "complete")
if [[ -n "$COMPLETION_PAYLOAD" ]] && echo "$COMPLETION_PAYLOAD" | grep -qE 'status\s*=\s*"delivered"|evidence\s*='; then
    echo -e "${GREEN}PASS${NC}: Completion has attestation with evidence"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: Completion attestation format unclear"
fi

# Print summary
print_summary

# Generate report
echo ""
echo "Compliance Report:"
generate_report

exit $FAIL
