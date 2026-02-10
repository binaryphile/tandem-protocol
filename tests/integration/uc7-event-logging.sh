#!/bin/bash
# UC7 Integration Test: Event Logging
# Verifies Contract, Completion, and Interaction entries are logged correctly
#
# Scenario: Full gate sequence with grade/improve cycle
# 1. Plan task (no Contract yet)
# 2. "proceed" (Gate 1) → Contract logged
# 3. "grade" → Interaction logged
# 4. "improve" → Interaction logged
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
assert_not_exists "No Contract before approval" "Contract:" "$TEST_CWD/plan-log.md"

# Gate 1: Approve plan
echo ""
echo "Step 2: Gate 1 - proceed..."
sleep 2
resume_session "proceed" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 2: Contract logged at Gate 1
echo ""
echo "Checkpoint 2: After Gate 1"
assert_exists "Contract entry exists" "Contract:" "$TEST_CWD/plan-log.md"
assert_exists "Contract has checkboxes" 'Contract:.*\[ \]' "$TEST_CWD/plan-log.md"
assert_not_exists "No Completion yet" "Completion:" "$TEST_CWD/plan-log.md"

# Grade
echo ""
echo "Step 3: Request grade..."
sleep 2
resume_session "grade" 5 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 3: Interaction logged for grade
echo ""
echo "Checkpoint 3: After grade"
assert_exists "Interaction entry for grade" 'Interaction:.*->' "$TEST_CWD/plan-log.md"
assert_exists "Grade mentioned in Interaction" 'Interaction:.*grade.*->' "$TEST_CWD/plan-log.md"

# Improve
echo ""
echo "Step 4: Request improve..."
sleep 2
resume_session "improve" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 4: Second Interaction logged
echo ""
echo "Checkpoint 4: After improve"
assert_count "2+ Interaction entries" 'Interaction:.*->' "$TEST_CWD/plan-log.md" 2

# Gate 2: Approve results
echo ""
echo "Step 5: Gate 2 - proceed..."
sleep 2
resume_session "proceed" 10 > /dev/null
sleep 1  # allow file writes to complete

# Checkpoint 5: Completion logged at Gate 2
echo ""
echo "Checkpoint 5: After Gate 2"
assert_exists "Completion entry exists" "Completion:" "$TEST_CWD/plan-log.md"
assert_exists "Completion has evidence" 'Completion:.*\[x\].*\([^)]+\)' "$TEST_CWD/plan-log.md"

# Validate entry formats using validators
echo ""
echo "Format validation..."

if [[ -f "$VALIDATORS" ]]; then
    source "$VALIDATORS"

    # Validate Contract format
    CONTRACT=$(get_contracts | head -1)
    if [[ -n "$CONTRACT" ]]; then
        if validate_contract_entry "$CONTRACT" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC}: Contract entry format valid"
            ((PASS++)) || true
        else
            echo -e "${RED}FAIL${NC}: Contract entry format invalid"
            ((FAIL++)) || true
        fi
    fi

    # Validate Completion format
    COMPLETION=$(get_completions | head -1)
    if [[ -n "$COMPLETION" ]]; then
        if validate_completion_entry "$COMPLETION" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC}: Completion entry format valid"
            ((PASS++)) || true
        else
            echo -e "${RED}FAIL${NC}: Completion entry format invalid"
            ((FAIL++)) || true
        fi
    fi

    # Validate Interaction format
    INTERACTION=$(get_interactions | head -1)
    if [[ -n "$INTERACTION" ]]; then
        if validate_interaction_entry "$INTERACTION" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC}: Interaction entry format valid"
            ((PASS++)) || true
        else
            echo -e "${RED}FAIL${NC}: Interaction entry format invalid"
            ((FAIL++)) || true
        fi
    fi

    # Validate criteria matching (Contract criteria appear in Completion)
    if [[ -n "$CONTRACT" && -n "$COMPLETION" ]]; then
        if match_criteria "$CONTRACT" "$COMPLETION" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC}: Criteria match between Contract and Completion"
            ((PASS++)) || true
        else
            echo -e "${YELLOW}WARN${NC}: Criteria mismatch (may be OK if scope changed)"
        fi
    fi
else
    echo "WARN: Validators not found, skipping format validation"
fi

# Print summary
print_summary

# Generate report
echo ""
echo "Compliance Report:"
generate_report

exit $FAIL
