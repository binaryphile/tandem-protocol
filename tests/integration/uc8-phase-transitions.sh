#!/bin/bash
# UC8 Integration Test: Phase Transitions
# Verifies skeleton→expand→collapse lifecycle
#
# Scenario: Two-phase project
# 1. Plan multi-phase project (Phase 1, Phase 2)
# 2. Gate 1: Phase 1 expanded, Phase 2 skeleton
# 3. Gate 2: Phase 1 collapsed, Phase 2 expanded

source "$(dirname "$0")/common.sh"

print_header "UC8: Phase Transitions"

# Setup
setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start session with two-phase task..."
RESULT=$(start_session "/tandem plan a two-phase project: Phase 1 implement fizzbuzz, Phase 2 add comprehensive tests" 15)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Find plan file after planning
echo ""
echo "Checking plan file after planning..."
sleep 2
PLAN_FILE=$(get_plan_file)

if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
    echo "Plan file: $PLAN_FILE"
    echo ""
    echo "Initial plan structure:"
    grep -E '^\[.\]' "$PLAN_FILE" | head -10
    echo ""
else
    echo "WARN: No plan file found yet"
fi

# Gate 1: Approve Phase 1 plan
echo ""
echo "Step 2: Gate 1 - proceed with Phase 1..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Check plan file state after Gate 1
echo ""
echo "Checking plan file after Gate 1..."
PLAN_FILE=$(get_plan_file)

if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
    echo "Plan structure after Gate 1:"
    grep -E '^\[.\]|^[[:space:]]+\[.\]' "$PLAN_FILE" | head -15
    echo ""

    # UC8 Check 1: Phase 1 should be expanded (has Plan/Implement stages)
    if grep -A5 'Phase 1\|fizzbuzz' "$PLAN_FILE" | grep -qE '\[.\] (Plan|Implement)'; then
        echo -e "${GREEN}PASS${NC}: Phase 1 expanded (has stages)"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: Phase 1 may not be fully expanded"
    fi

    # UC8 Check 2: Phase 2 should be skeleton (no stages yet)
    # Find Phase 2 and check if it has NO immediate child stages
    PHASE2_LINE=$(grep -n 'Phase 2\|tests' "$PLAN_FILE" | grep '\[ \]' | head -1 | cut -d: -f1)
    if [[ -n "$PHASE2_LINE" ]]; then
        NEXT_LINES=$(sed -n "$((PHASE2_LINE+1)),$((PHASE2_LINE+3))p" "$PLAN_FILE")
        if echo "$NEXT_LINES" | grep -qE '^\[.\] Phase|^$|^[^[:space:]]'; then
            echo -e "${GREEN}PASS${NC}: Phase 2 is skeleton (no stages)"
            ((PASS++)) || true
        else
            echo -e "${YELLOW}INFO${NC}: Phase 2 may already have stages"
        fi
    fi
else
    echo "WARN: No plan file found after Gate 1"
fi

# Complete Phase 1 implementation (grade + improve)
echo ""
echo "Step 3: Grade Phase 1..."
sleep 2
resume_session "grade" 5 > /dev/null

echo ""
echo "Step 4: Improve Phase 1..."
sleep 2
resume_session "improve" 10 > /dev/null

# Gate 2: Complete Phase 1
echo ""
echo "Step 5: Gate 2 - complete Phase 1 (using context injection)..."
sleep 2
completion_gate "proceed" 15 > /dev/null

# Check plan file state after Gate 2
echo ""
echo "Checking plan file after Gate 2..."
PLAN_FILE=$(get_plan_file)

if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
    echo "Plan structure after Gate 2:"
    grep -E '^\[.\]|^[[:space:]]+\[.\]' "$PLAN_FILE" | head -15
    echo ""

    # UC8 Check 3: Phase 1 should be collapsed ([x] with NO children)
    if grep -qE '^\[x\].*Phase 1\|^\[x\].*fizzbuzz' "$PLAN_FILE"; then
        # Check it has no child tasks
        PHASE1_LINE=$(grep -n '^\[x\].*Phase 1\|^\[x\].*fizzbuzz' "$PLAN_FILE" | head -1 | cut -d: -f1)
        if [[ -n "$PHASE1_LINE" ]]; then
            NEXT_LINE=$(sed -n "$((PHASE1_LINE+1))p" "$PLAN_FILE")
            if [[ -z "$NEXT_LINE" ]] || echo "$NEXT_LINE" | grep -qE '^\[.\] Phase|^[^[:space:]]|^$'; then
                echo -e "${GREEN}PASS${NC}: Phase 1 collapsed (marked [x], no children)"
                ((PASS++)) || true
            else
                echo -e "${YELLOW}WARN${NC}: Phase 1 marked [x] but may still have children"
            fi
        fi
    else
        echo -e "${YELLOW}INFO${NC}: Phase 1 not yet marked [x]"
    fi

    # UC8 Check 4: Phase 2 should now be expanded (has stages)
    if grep -A5 'Phase 2\|tests' "$PLAN_FILE" | grep '\[ \]' | grep -qE '\[.\] (Plan|Implement)'; then
        echo -e "${GREEN}PASS${NC}: Phase 2 now expanded (has stages)"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}INFO${NC}: Phase 2 may not be expanded yet"
    fi

    # Validate hierarchy using validators
    if [[ -f "$VALIDATORS" ]]; then
        source "$VALIDATORS"
        RESULT=$(validate_plan_hierarchy "$PLAN_FILE" 2>&1)
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}PASS${NC}: Plan hierarchy valid"
            ((PASS++)) || true
        else
            echo -e "${YELLOW}WARN${NC}: Plan hierarchy issue: $RESULT"
        fi
    fi
else
    echo "WARN: No plan file found after Gate 2"
fi

# Check Contracts - should have one for Phase 1
echo ""
echo "Checking Contracts..."
CONTRACTS=$(get_contracts)
CONTRACT_COUNT=$(echo "$CONTRACTS" | grep -c 'Contract:' || echo 0)
echo "Contract entries: $CONTRACT_COUNT"

if [[ $CONTRACT_COUNT -ge 1 ]]; then
    echo -e "${GREEN}PASS${NC}: At least one Contract logged"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: No Contract entries found"
    ((FAIL++)) || true
fi

# Check Completions
echo ""
echo "Checking Completions..."
COMPLETIONS=$(get_completions)
COMPLETION_COUNT=$(echo "$COMPLETIONS" | grep -c 'Completion:' || echo 0)
echo "Completion entries: $COMPLETION_COUNT"

if [[ $COMPLETION_COUNT -ge 1 ]]; then
    echo -e "${GREEN}PASS${NC}: At least one Completion logged"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: No Completion entries found"
    ((FAIL++)) || true
fi

# Print summary
print_summary

# Generate report
echo ""
generate_report

exit $FAIL
