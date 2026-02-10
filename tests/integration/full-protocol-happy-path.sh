#!/bin/bash
# Full Protocol Integration Test - Happy Path
# Complete two-phase project exercising all UCs
#
# Flow:
# START → [UC2] Plan Phase 1 → [UC3] Quote/Grade/Block → Gate 1
#   → [UC7] Contract → [UC8] Expand → Implement → [UC5] Line refs
#   → [UC6] Grade/Lesson → Improve → Gate 2
#   → [UC7] Completion → [UC8] Collapse → Phase 2 → repeat → DONE

source "$(dirname "$0")/common.sh"

print_header "Full Protocol - Happy Path"

# Track checkpoints
declare -A CHECKPOINTS

checkpoint() {
    local name="$1" status="$2"
    CHECKPOINTS["$name"]="$status"
    if [[ "$status" == "PASS" ]]; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
    fi
}

# Setup
setup_workspace
trap 'cleanup true' EXIT

echo "Starting full protocol walk..."
echo ""

# ============================================================================
# PHASE 1
# ============================================================================

echo "═══════════════════════════════════════"
echo "PHASE 1: Fizzbuzz Implementation"
echo "═══════════════════════════════════════"
echo ""

# Step 1: Start planning
echo "Step 1: Plan Phase 1..."
RESULT=$(start_session "/tandem plan a two-phase project: Phase 1 implement fizzbuzz, Phase 2 add tests" 15)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Checkpoint 1: After start
echo ""
echo "Checkpoint 1: After start"
if ! grep -q 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    checkpoint "No Contract before approval" "PASS"
    ((PASS++)) || true
else
    checkpoint "No Contract before approval" "FAIL"
    ((FAIL++)) || true
fi

# Step 2: Gate 1 - Phase 1
echo ""
echo "Step 2: Gate 1 (Phase 1)..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Checkpoint 2: After Gate 1 Phase 1
echo ""
echo "Checkpoint 2: After Gate 1 (Phase 1)"

# UC7: Contract logged
if grep -qE 'Contract:.*\[ \]' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    checkpoint "[UC7] Contract with criteria" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] Contract with criteria" "FAIL"
    ((FAIL++)) || true
fi

# UC8: Plan expanded
PLAN_FILE=$(get_plan_file)
if [[ -n "$PLAN_FILE" ]] && grep -qE '\[.\] (Plan|Implement)' "$PLAN_FILE" 2>/dev/null; then
    checkpoint "[UC8] Plan file expanded" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC8] Plan file expanded" "FAIL"
    ((FAIL++)) || true
fi

# Step 3: Grade
echo ""
echo "Step 3: Grade Phase 1..."
sleep 2
resume_session "grade" 5 > /dev/null

# Checkpoint 3: After grade
echo ""
echo "Checkpoint 3: After grade"

# UC7: Interaction logged
if grep -qE 'Interaction:.*grade.*->' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    checkpoint "[UC7] Interaction for grade" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] Interaction for grade" "FAIL"
    ((FAIL++)) || true
fi

# Step 4: Improve
echo ""
echo "Step 4: Improve Phase 1..."
sleep 2
resume_session "improve" 10 > /dev/null

# Checkpoint 4: After improve
echo ""
echo "Checkpoint 4: After improve"

# UC7: 2+ Interactions
INTERACTION_COUNT=$(grep -cE 'Interaction:.*->' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
if [[ $INTERACTION_COUNT -ge 2 ]]; then
    checkpoint "[UC7] 2+ Interactions" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] 2+ Interactions" "FAIL"
    ((FAIL++)) || true
fi

# Step 5: Gate 2 - Phase 1
echo ""
echo "Step 5: Gate 2 (Phase 1)..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Checkpoint 5: After Gate 2 Phase 1
echo ""
echo "Checkpoint 5: After Gate 2 (Phase 1)"

# UC7: Completion logged
if grep -qE 'Completion:.*\[x\].*\([^)]+\)' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    checkpoint "[UC7] Completion with evidence" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] Completion with evidence" "FAIL"
    ((FAIL++)) || true
fi

# UC6: Check for Lesson (optional)
if grep -qE 'Lesson:.*->' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    checkpoint "[UC6] Lesson captured" "PASS"
    ((PASS++)) || true
else
    echo "  [UC6] No Lesson entry (OK if no non-actionable gaps)"
fi

# UC8: Phase 1 should be collapsed
PLAN_FILE=$(get_plan_file)
if [[ -n "$PLAN_FILE" ]] && grep -qE '^\[x\].*Phase 1\|^\[x\].*fizzbuzz' "$PLAN_FILE" 2>/dev/null; then
    checkpoint "[UC8] Phase 1 collapsed" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC8] Phase 1 collapsed" "FAIL"
    ((FAIL++)) || true
fi

# ============================================================================
# PHASE 2
# ============================================================================

echo ""
echo "═══════════════════════════════════════"
echo "PHASE 2: Tests Implementation"
echo "═══════════════════════════════════════"
echo ""

# Step 6: Plan should auto-transition to Phase 2
echo "Step 6: Enter Phase 2 planning..."
sleep 2
resume_session "continue to Phase 2" 10 > /dev/null

# Checkpoint 6: After Phase 2 plan entry
echo ""
echo "Checkpoint 6: Phase 2 plan entry"

# UC3: Should be in plan mode (implicit)
echo "  [UC3] Plan mode entry (implicit in flow)"

# UC8: Phase 2 should be expanded
PLAN_FILE=$(get_plan_file)
if [[ -n "$PLAN_FILE" ]] && grep -A5 'Phase 2\|tests' "$PLAN_FILE" 2>/dev/null | grep -qE '\[.\] (Plan|Implement)'; then
    checkpoint "[UC8] Phase 2 expanded" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC8] Phase 2 expanded" "FAIL"
    ((FAIL++)) || true
fi

# Step 7: Gate 1 - Phase 2
echo ""
echo "Step 7: Gate 1 (Phase 2)..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Checkpoint 7: After Gate 1 Phase 2
echo ""
echo "Checkpoint 7: After Gate 1 (Phase 2)"

# UC7: Second Contract
CONTRACT_COUNT=$(grep -cE 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
if [[ $CONTRACT_COUNT -ge 2 ]]; then
    checkpoint "[UC7] Second Contract" "PASS"
    ((PASS++)) || true
else
    echo "  [UC7] Second Contract not found (may be single-Contract flow)"
fi

# Step 8: Grade
echo ""
echo "Step 8: Grade Phase 2..."
sleep 2
resume_session "grade" 5 > /dev/null

# Checkpoint 8: After grade Phase 2
echo ""
echo "Checkpoint 8: After grade (Phase 2)"

INTERACTION_COUNT=$(grep -cE 'Interaction:.*grade.*->' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
if [[ $INTERACTION_COUNT -ge 2 ]]; then
    checkpoint "[UC7] Grade Interactions" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] Grade Interactions" "FAIL"
    ((FAIL++)) || true
fi

# Step 9: Improve
echo ""
echo "Step 9: Improve Phase 2..."
sleep 2
resume_session "improve" 10 > /dev/null

# Step 10: Gate 2 - Phase 2
echo ""
echo "Step 10: Gate 2 (Phase 2)..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Checkpoint 10: After Gate 2 Phase 2
echo ""
echo "Checkpoint 10: After Gate 2 (Phase 2)"

# UC7: Second Completion
COMPLETION_COUNT=$(grep -cE 'Completion:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
if [[ $COMPLETION_COUNT -ge 2 ]]; then
    checkpoint "[UC7] Second Completion" "PASS"
    ((PASS++)) || true
else
    checkpoint "[UC7] Second Completion" "FAIL"
    ((FAIL++)) || true
fi

# UC8: Both phases collapsed
PLAN_FILE=$(get_plan_file)
if [[ -n "$PLAN_FILE" ]]; then
    COLLAPSED=$(grep -cE '^\[x\].*Phase' "$PLAN_FILE" 2>/dev/null || echo 0)
    if [[ $COLLAPSED -ge 2 ]]; then
        checkpoint "[UC8] All phases collapsed" "PASS"
        ((PASS++)) || true
    else
        checkpoint "[UC8] All phases collapsed" "FAIL"
        ((FAIL++)) || true
    fi
fi

# ============================================================================
# FINAL CHECKS
# ============================================================================

echo ""
echo "═══════════════════════════════════════"
echo "FINAL CHECKS"
echo "═══════════════════════════════════════"
echo ""

# Checkpoint 11: Isolation
echo "Checkpoint 11: Isolation"
if [[ ! -f "$PROJECT_DIR/bin/fizzbuzz" ]]; then
    checkpoint "No files leaked to real project" "PASS"
    ((PASS++)) || true
else
    checkpoint "No files leaked to real project" "FAIL"
    ((FAIL++)) || true
fi

# Checkpoint 12: Artifact validation
echo ""
echo "Checkpoint 12: Artifact validation"

if [[ -f "$VALIDATORS" ]]; then
    source "$VALIDATORS"

    # Validate all Contracts
    while IFS= read -r contract; do
        if validate_contract_entry "$contract" >/dev/null 2>&1; then
            checkpoint "Contract format valid" "PASS"
            ((PASS++)) || true
            break  # Just check first one
        fi
    done < <(get_contracts)

    # Validate all Completions
    while IFS= read -r completion; do
        if validate_completion_entry "$completion" >/dev/null 2>&1; then
            checkpoint "Completion format valid" "PASS"
            ((PASS++)) || true
            break
        fi
    done < <(get_completions)

    # Validate plan hierarchy
    PLAN_FILE=$(get_plan_file)
    if [[ -n "$PLAN_FILE" ]]; then
        if validate_plan_hierarchy "$PLAN_FILE" >/dev/null 2>&1; then
            checkpoint "Plan hierarchy valid" "PASS"
            ((PASS++)) || true
        else
            checkpoint "Plan hierarchy valid" "FAIL"
            ((FAIL++)) || true
        fi
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
print_summary

# Generate detailed report
echo ""
echo "Compliance Report:"
generate_report

# Show plan-log.md summary
echo ""
echo "plan-log.md entries:"
echo "  Contracts: $(grep -cE 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)"
echo "  Completions: $(grep -cE 'Completion:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)"
echo "  Interactions: $(grep -cE 'Interaction:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)"
echo "  Lessons: $(grep -cE 'Lesson:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)"

exit $FAIL
