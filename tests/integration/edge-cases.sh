#!/bin/bash
# Edge Cases Integration Test
# Verifies protocol handles non-happy-path scenarios gracefully
#
# Cases covered:
# 1. Reject plan at Gate 1
# 2. Scope change mid-phase
# 3. Empty plan file
# 4. Grade perfect (100/100)
# 5. Multi-session resume
# 6. Missing plan-log.md

source "$(dirname "$0")/common.sh"

print_header "Edge Cases"

# Track case results
declare -A CASE_RESULTS

run_case() {
    local case_name="$1"
    echo ""
    echo "─────────────────────────────────────────"
    echo "CASE: $case_name"
    echo "─────────────────────────────────────────"
}

# ============================================================================
# CASE 1: Reject Plan at Gate 1
# ============================================================================

run_case "Reject plan at Gate 1"

setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start planning session..."
RESULT=$(start_session "/tandem plan to implement fizzbuzz so we can test rejection" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["reject_plan"]="SKIP"
else
    echo "Session: $SESSION_ID"

    # Reject the plan
    echo ""
    echo "Step 2: Reject the plan..."
    sleep 2
    REJECT_RESULT=$(resume_session "no, I want a different approach using recursion" 10)

    # Check: No Contract should be logged
    echo ""
    echo "Checking assertions..."
    if ! grep -q 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}: No Contract logged after rejection"
        ((PASS++)) || true
        CASE_RESULTS["reject_plan"]="PASS"
    else
        echo -e "${RED}FAIL${NC}: Contract logged despite rejection"
        ((FAIL++)) || true
        CASE_RESULTS["reject_plan"]="FAIL"
    fi

    # Check: Should return to planning (mention recursion or new approach)
    if echo "$REJECT_RESULT" | grep -qiE 'recursion|recursive|new approach|revised|updated|different'; then
        echo -e "${GREEN}PASS${NC}: Returned to planning with new approach"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: May not have fully revised plan"
    fi

    # Check: Should still be asking for approval (blocking prompt)
    if echo "$REJECT_RESULT" | grep -qiE 'proceed\?|may I|approve|ready'; then
        echo -e "${GREEN}PASS${NC}: Still blocking for approval"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: May have proceeded without approval"
    fi

    # Check: No implementation files created
    if [[ ! -f "$TEST_CWD/fizzbuzz" && ! -f "$TEST_CWD/bin/fizzbuzz" ]]; then
        echo -e "${GREEN}PASS${NC}: No implementation before approval"
        ((PASS++)) || true
    else
        echo -e "${RED}FAIL${NC}: Implementation started despite rejection"
        ((FAIL++)) || true
    fi
fi

cleanup false

# ============================================================================
# CASE 2: Scope Change Mid-Phase
# ============================================================================

run_case "Scope change mid-phase"

setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start and approve plan..."
RESULT=$(start_session "/tandem plan to implement fizzbuzz" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["scope_change"]="SKIP"
else
    echo "Session: $SESSION_ID"

    # Approve the plan
    sleep 2
    implementation_gate "proceed" 10 > /dev/null

    # Contract should exist now
    CONTRACT_BEFORE=$(grep -c 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)

    # Mid-phase scope change
    echo ""
    echo "Step 2: Request scope change..."
    sleep 2
    SCOPE_RESULT=$(resume_session "actually, I need fizzbuzz to also handle negative numbers" 10)

    # Check: Should handle gracefully (either new Contract or amendment note)
    echo ""
    echo "Checking assertions..."
    CONTRACT_AFTER=$(grep -c 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
    INTERACTION_COUNT=$(grep -c 'Interaction:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)

    if [[ $CONTRACT_AFTER -gt $CONTRACT_BEFORE ]] || [[ $INTERACTION_COUNT -ge 1 ]]; then
        echo -e "${GREEN}PASS${NC}: Scope change handled (new Contract or Interaction logged)"
        ((PASS++)) || true
        CASE_RESULTS["scope_change"]="PASS"
    else
        echo -e "${YELLOW}WARN${NC}: Scope change may not have been logged"
        CASE_RESULTS["scope_change"]="WARN"
    fi

    # Check: Response acknowledges scope change
    if echo "$SCOPE_RESULT" | grep -qiE 'negative|scope|change|update|revise|additional'; then
        echo -e "${GREEN}PASS${NC}: Response acknowledges scope change"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: Response may not acknowledge scope change"
    fi

    # Check: Should return to planning or ask about new requirements
    if echo "$SCOPE_RESULT" | grep -qiE 'plan|approach|how|requirement|\?'; then
        echo -e "${GREEN}PASS${NC}: Engaging with new requirements"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: May not be engaging with scope change"
    fi
fi

cleanup false

# ============================================================================
# CASE 3: Empty Plan File
# ============================================================================

run_case "Empty plan file"

setup_workspace
trap 'cleanup true' EXIT

# Create an empty plan file
mkdir -p ~/.claude/plans
EMPTY_PLAN=~/.claude/plans/test-empty-plan.md
touch "$EMPTY_PLAN"

echo "Step 1: Start session with empty plan file..."
RESULT=$(start_session "/tandem continue with the existing plan" 5)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["empty_plan"]="SKIP"
else
    echo "Session: $SESSION_ID"

    # Check: Should not crash, should prompt for new plan or clarification
    echo ""
    echo "Checking assertions..."
    if echo "$RESULT" | grep -qiE 'plan|create|define|what.*task|clarify'; then
        echo -e "${GREEN}PASS${NC}: Handled empty plan gracefully"
        ((PASS++)) || true
        CASE_RESULTS["empty_plan"]="PASS"
    else
        echo -e "${YELLOW}WARN${NC}: Behavior with empty plan unclear"
        CASE_RESULTS["empty_plan"]="WARN"
    fi
fi

rm -f "$EMPTY_PLAN"
cleanup false

# ============================================================================
# CASE 4: Perfect Grade (100/100)
# ============================================================================

run_case "Perfect grade (100/100)"

setup_workspace
trap 'cleanup true' EXIT

# Create a complete, well-structured deliverable
mkdir -p "$TEST_CWD/bin"
cat > "$TEST_CWD/bin/fizzbuzz" << 'EOF'
#!/bin/bash
# Complete fizzbuzz with all edge cases handled
for i in $(seq 1 100); do
    if (( i % 15 == 0 )); then echo "FizzBuzz"
    elif (( i % 3 == 0 )); then echo "Fizz"
    elif (( i % 5 == 0 )); then echo "Buzz"
    else echo "$i"
    fi
done
EOF
chmod +x "$TEST_CWD/bin/fizzbuzz"

cat > "$TEST_CWD/test_fizzbuzz.sh" << 'EOF'
#!/bin/bash
# Complete test suite
OUTPUT=$(./bin/fizzbuzz)
[[ $(echo "$OUTPUT" | head -1) == "1" ]] && echo "PASS: 1" || echo "FAIL: 1"
[[ $(echo "$OUTPUT" | sed -n '3p') == "Fizz" ]] && echo "PASS: Fizz at 3" || echo "FAIL: Fizz"
[[ $(echo "$OUTPUT" | sed -n '5p') == "Buzz" ]] && echo "PASS: Buzz at 5" || echo "FAIL: Buzz"
[[ $(echo "$OUTPUT" | sed -n '15p') == "FizzBuzz" ]] && echo "PASS: FizzBuzz at 15" || echo "FAIL: FizzBuzz"
[[ $(echo "$OUTPUT" | wc -l) == "100" ]] && echo "PASS: 100 lines" || echo "FAIL: count"
EOF
chmod +x "$TEST_CWD/test_fizzbuzz.sh"

git add -A && git commit -q -m "complete fizzbuzz"

echo "Step 1: Start session with complete deliverable..."
RESULT=$(start_session "/tandem plan to verify fizzbuzz is complete and working" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["perfect_grade"]="SKIP"
else
    echo "Session: $SESSION_ID"

    # Approve and request grade
    sleep 2
    implementation_gate "proceed" 10 > /dev/null

    echo ""
    echo "Step 2: Request grade..."
    sleep 2
    GRADE_RESULT=$(resume_session "grade" 5)

    # Check: Should give high grade, no Lesson entry needed
    echo ""
    echo "Checking assertions..."
    if echo "$GRADE_RESULT" | grep -qiE '100|A\+|perfect|excellent|complete'; then
        echo -e "${GREEN}PASS${NC}: High/perfect grade given"
        ((PASS++)) || true
        CASE_RESULTS["perfect_grade"]="PASS"
    else
        echo -e "${YELLOW}INFO${NC}: Grade result: $(echo "$GRADE_RESULT" | grep -oE '[0-9]+/100|[A-F][+-]?' | head -1)"
        CASE_RESULTS["perfect_grade"]="INFO"
    fi

    # Check: No Lesson entry for perfect work
    LESSON_COUNT=$(grep -c 'Lesson:' "$TEST_CWD/plan-log.md" 2>/dev/null || echo 0)
    if [[ $LESSON_COUNT -eq 0 ]]; then
        echo -e "${GREEN}PASS${NC}: No Lesson entry for complete work"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}INFO${NC}: Lesson entry present ($LESSON_COUNT)"
    fi
fi

cleanup false

# ============================================================================
# CASE 5: Multi-Session Resume
# ============================================================================

run_case "Multi-session resume"

setup_workspace
trap 'cleanup true' EXIT

echo "Step 1: Start first session..."
RESULT=$(start_session "/tandem plan a two-phase project: Phase 1 fizzbuzz, Phase 2 tests" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["multi_session"]="SKIP"
else
    FIRST_SESSION="$SESSION_ID"
    echo "First session: $FIRST_SESSION"

    # Approve Phase 1
    sleep 2
    implementation_gate "proceed" 10 > /dev/null

    # Simulate session break by clearing session ID
    echo ""
    echo "Step 2: Simulating session break..."
    sleep 2

    # Resume with same session ID
    echo ""
    echo "Step 3: Resume previous session..."
    SESSION_ID="$FIRST_SESSION"
    RESUME_RESULT=$(resume_session "continue where we left off" 5)

    # Check: Session state should be preserved
    echo ""
    echo "Checking assertions..."
    if [[ -n "$RESUME_RESULT" ]]; then
        echo -e "${GREEN}PASS${NC}: Session resumed successfully"
        ((PASS++)) || true
        CASE_RESULTS["multi_session"]="PASS"
    else
        echo -e "${RED}FAIL${NC}: Session resume failed"
        ((FAIL++)) || true
        CASE_RESULTS["multi_session"]="FAIL"
    fi

    # Check: Contract should still exist from before
    if grep -q 'Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}: Contract preserved across sessions"
        ((PASS++)) || true
    else
        echo -e "${YELLOW}WARN${NC}: Contract may not have been logged before break"
    fi
fi

cleanup false

# ============================================================================
# CASE 6: Missing plan-log.md
# ============================================================================

run_case "Missing plan-log.md"

setup_workspace
trap 'cleanup true' EXIT

# Remove plan-log.md
rm -f "$TEST_CWD/plan-log.md"

echo "Step 1: Start session without plan-log.md..."
RESULT=$(start_session "/tandem plan to implement fizzbuzz" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    CASE_RESULTS["missing_planlog"]="SKIP"
else
    echo "Session: $SESSION_ID"

    # Approve plan - should create plan-log.md
    sleep 2
    implementation_gate "proceed" 10 > /dev/null

    # Check: plan-log.md should be created automatically
    echo ""
    echo "Checking assertions..."
    if [[ -f "$TEST_CWD/plan-log.md" ]]; then
        echo -e "${GREEN}PASS${NC}: plan-log.md created automatically"
        ((PASS++)) || true
        CASE_RESULTS["missing_planlog"]="PASS"

        # Check: Contract should be logged
        if grep -q 'Contract:' "$TEST_CWD/plan-log.md"; then
            echo -e "${GREEN}PASS${NC}: Contract logged to new file"
            ((PASS++)) || true
        else
            echo -e "${YELLOW}WARN${NC}: Contract not logged yet"
        fi
    else
        echo -e "${RED}FAIL${NC}: plan-log.md not created"
        ((FAIL++)) || true
        CASE_RESULTS["missing_planlog"]="FAIL"
    fi
fi

cleanup false

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "═══════════════════════════════════════"
echo "EDGE CASES SUMMARY"
echo "═══════════════════════════════════════"
echo ""

for case_name in "${!CASE_RESULTS[@]}"; do
    result="${CASE_RESULTS[$case_name]}"
    case "$result" in
        PASS) echo -e "  ${GREEN}✓${NC} $case_name" ;;
        FAIL) echo -e "  ${RED}✗${NC} $case_name" ;;
        WARN) echo -e "  ${YELLOW}~${NC} $case_name (warning)" ;;
        INFO) echo -e "  ${YELLOW}i${NC} $case_name (info)" ;;
        SKIP) echo -e "  ${YELLOW}-${NC} $case_name (skipped)" ;;
    esac
done

print_summary

echo ""
generate_report

exit $FAIL
