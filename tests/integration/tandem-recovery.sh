#!/bin/bash
# Tandem Recovery Test
# Verifies /tandem can recover compliance after drift
#
# Theory: Sessions drift off protocol, but /tandem reminder kicks them back
#
# Scenarios:
# 1. Start WITHOUT /tandem, verify drift (no Contract, no blocking)
# 2. Inject /tandem, verify recovery (Contract logged, blocking prompt)
# 3. Start with drift mid-session, recover with /tandem

source "$(dirname "$0")/common.sh"

print_header "Tandem Recovery Test"

#═══════════════════════════════════════
# SCENARIO 1: Initial Drift → Recovery
#═══════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
echo "SCENARIO 1: Start drifted, recover with /tandem"
echo "═══════════════════════════════════════"

setup_workspace
trap 'cleanup true' EXIT

echo ""
echo "Step 1: Start session WITHOUT /tandem (expect drift)..."
# Just ask to implement something, no protocol trigger
RESULT=$(start_session "implement fizzbuzz in python" 8)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Check for drift indicators
echo ""
echo "Checking for drift..."
DRIFTED=false

# No Contract should exist (drifted = no gate)
if ! grep -q "Contract:" "$TEST_CWD/plan-log.md" 2>/dev/null; then
    echo -e "${GREEN}CONFIRMED${NC}: No Contract (session drifted)"
    DRIFTED=true
else
    echo -e "${YELLOW}UNEXPECTED${NC}: Contract exists without /tandem"
fi

# Check if implementation happened without approval
if [[ -f "$TEST_CWD/fizzbuzz.py" ]] || ls "$TEST_CWD"/*.py 2>/dev/null | grep -q .; then
    echo -e "${GREEN}CONFIRMED${NC}: Implementation without gate approval (drift)"
    DRIFTED=true
else
    echo -e "${YELLOW}INFO${NC}: No implementation yet"
fi

if [[ "$DRIFTED" != "true" ]]; then
    echo -e "${YELLOW}WARN${NC}: Session may not have drifted as expected"
fi

# Now inject /tandem to recover
echo ""
echo "Step 2: Inject /tandem to recover compliance..."
sleep 2
RECOVERY_RESULT=$(resume_session "/tandem we need to follow the protocol for the fizzbuzz task" 10)

# Check for recovery indicators
echo ""
echo "Checking for recovery..."

# Should now have blocking prompt or plan mode behavior
if echo "$RECOVERY_RESULT" | grep -qiE "may i proceed|proceed\?|approve|gate|plan"; then
    echo -e "${GREEN}PASS${NC}: Recovery shows protocol awareness"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: No clear protocol language in recovery"
fi

# Approve to trigger Contract
echo ""
echo "Step 3: Approve to verify Contract logging..."
sleep 2
implementation_gate "proceed" 10 > /dev/null

# Check Contract now exists
if grep -q "Contract:" "$TEST_CWD/plan-log.md" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}: Contract logged after /tandem recovery"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: No Contract after recovery + approval"
    ((FAIL++)) || true
fi

# Store scenario 1 results
S1_PASS=$PASS
S1_FAIL=$FAIL
PASS=0
FAIL=0

#═══════════════════════════════════════
# SCENARIO 2: Mid-session Drift → Recovery
#═══════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
echo "SCENARIO 2: Drift mid-session, recover"
echo "═══════════════════════════════════════"

setup_workspace

echo ""
echo "Step 1: Start correctly with /tandem..."
RESULT=$(start_session "/tandem plan to create a hello world script" 10)
SESSION_ID=$(extract_session_id "$RESULT")
echo "Session: $SESSION_ID"

echo ""
echo "Step 2: Approve plan (Gate 1)..."
sleep 2
implementation_gate "proceed" 10 > /dev/null

# Verify Contract logged
if grep -q "Contract:" "$TEST_CWD/plan-log.md" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}: Contract logged at Gate 1"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: No Contract at Gate 1"
    ((FAIL++)) || true
fi

echo ""
echo "Step 3: Make off-protocol request (induce drift)..."
sleep 2
# Ask for something that might cause drift from current task
DRIFT_RESULT=$(resume_session "actually, also add a goodbye function and refactor everything" 8)

echo ""
echo "Step 4: Check for drift indicators..."
# Drift = no new Contract for scope change, or proceeding without gate
if echo "$DRIFT_RESULT" | grep -qiE "may i proceed|gate|approve"; then
    echo -e "${YELLOW}INFO${NC}: Session maintained protocol (no drift)"
else
    echo -e "${GREEN}CONFIRMED${NC}: Session drifted (no gate language)"
fi

echo ""
echo "Step 5: Inject /tandem to recover..."
sleep 2
RECOVERY_RESULT=$(resume_session "/tandem check where we are - we changed scope" 10)

# Check recovery
if echo "$RECOVERY_RESULT" | grep -qiE "scope|contract|plan|gate|proceed"; then
    echo -e "${GREEN}PASS${NC}: /tandem triggered protocol awareness"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: /tandem didn't recover protocol awareness"
    ((FAIL++)) || true
fi

# Store scenario 2 results
S2_PASS=$PASS
S2_FAIL=$FAIL
PASS=0
FAIL=0

#═══════════════════════════════════════
# SCENARIO 3: Multiple /tandem recoveries
#═══════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
echo "SCENARIO 3: Repeated drift/recovery cycles"
echo "═══════════════════════════════════════"

setup_workspace

echo ""
echo "Step 1: Start with drift..."
RESULT=$(start_session "make a calculator" 5)
SESSION_ID=$(extract_session_id "$RESULT")
echo "Session: $SESSION_ID"

echo ""
echo "Step 2: First /tandem recovery..."
sleep 2
R1=$(resume_session "/tandem let's follow the protocol" 8)
RECOVERY_1=$(echo "$R1" | grep -ciE "plan|gate|proceed|contract" || echo 0)

echo ""
echo "Step 3: Induce drift again..."
sleep 2
resume_session "just do it quickly, skip the formalities" 5 > /dev/null

echo ""
echo "Step 4: Second /tandem recovery..."
sleep 2
R2=$(resume_session "/tandem no really, we need to follow protocol" 8)
RECOVERY_2=$(echo "$R2" | grep -ciE "plan|gate|proceed|contract" || echo 0)

echo ""
echo "Recovery effectiveness:"
echo "  First /tandem: $RECOVERY_1 protocol terms"
echo "  Second /tandem: $RECOVERY_2 protocol terms"

if [[ $RECOVERY_1 -gt 0 ]] && [[ $RECOVERY_2 -gt 0 ]]; then
    echo -e "${GREEN}PASS${NC}: /tandem recovers compliance repeatedly"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: /tandem recovery inconsistent"
    ((FAIL++)) || true
fi

S3_PASS=$PASS
S3_FAIL=$FAIL

#═══════════════════════════════════════
# SUMMARY
#═══════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
echo "TANDEM RECOVERY TEST SUMMARY"
echo "═══════════════════════════════════════"
echo ""
echo "Scenario 1 (Initial drift → recovery): $S1_PASS passed, $S1_FAIL failed"
echo "Scenario 2 (Mid-session drift → recovery): $S2_PASS passed, $S2_FAIL failed"
echo "Scenario 3 (Repeated recovery): $S3_PASS passed, $S3_FAIL failed"
echo ""

TOTAL_PASS=$((S1_PASS + S2_PASS + S3_PASS))
TOTAL_FAIL=$((S1_FAIL + S2_FAIL + S3_FAIL))
TOTAL=$((TOTAL_PASS + TOTAL_FAIL))

echo "============================================"
echo "Results: $TOTAL_PASS passed, $TOTAL_FAIL failed"
echo "============================================"

# Generate report
PASS=$TOTAL_PASS
FAIL=$TOTAL_FAIL
generate_report

if [[ $TOTAL_FAIL -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}THEORY VALIDATED${NC}: /tandem recovers compliance after drift"
else
    echo ""
    echo -e "${YELLOW}THEORY PARTIALLY VALIDATED${NC}: /tandem recovery is imperfect"
fi

exit $TOTAL_FAIL
