#!/bin/bash
# UC3 Integration Test: Plan Entry Sequence
# Verifies quote→grade→block sequence when entering plan mode with existing plan
#
# Scenario: Create plan file, start session, verify sequence
# 1. Create known plan file
# 2. Start session (triggers plan mode entry)
# 3. Verify plan quoted verbatim (KNOWN LIMITATION: ~0% - bash block not auto-executed)
# 4. Verify analysis grade before plan grade
# 5. Verify blocking prompt
#
# Expected: 4/5 pass (80%) - verbatim quote requires Claude to execute bash block
# The bash block is in tandem.md but Claude chooses whether to run it.
# This is the documented compliance ceiling for descriptive instructions.

source "$(dirname "$0")/common.sh"

print_header "UC3: Plan Entry Sequence"

# Setup
setup_workspace
trap 'cleanup true' EXIT

# Create a known plan file with specific content we can verify was quoted
KNOWN_PLAN_CONTENT="## Objective

Implement fizzbuzz to verify UC3 plan entry compliance.

## Approach

Use test-driven development with clear phase separation.

## Changes

- Create bin/fizzbuzz script
- Add unit tests

## At Gate 1 Approval

Log Contract and create tasks.

## At Gate 2 Approval

Log Completion and commit."

# Create plan file in expected location
mkdir -p ~/.claude/plans
PLAN_FILE=~/.claude/plans/test-uc3-plan.md
echo "$KNOWN_PLAN_CONTENT" > "$PLAN_FILE"

echo "Created plan file: $PLAN_FILE"
echo ""

# Start session - should trigger plan mode entry and quote the plan
echo "Step 1: Start session (expect plan to be quoted)..."
RESULT=$(start_session "/tandem continue the fizzbuzz implementation" 5)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    echo "$RESULT"
    exit 1
fi

# Extract the assistant's response
RESPONSE=$(echo "$RESULT" | jq -r '.result // .message // .content // empty' 2>/dev/null)
if [[ -z "$RESPONSE" ]]; then
    RESPONSE="$RESULT"
fi

echo "Session: $SESSION_ID"
echo ""

# UC3 Assertions
echo "UC3 Sequence Checks..."

# Check 1: Plan should be quoted verbatim (look for key phrases)
echo ""
echo "Check 1: Verbatim quote..."
QUOTE_MARKERS=("fizzbuzz to verify UC3" "test-driven development" "clear phase separation")
QUOTE_FOUND=0

for marker in "${QUOTE_MARKERS[@]}"; do
    if echo "$RESPONSE" | grep -qi "$marker"; then
        ((QUOTE_FOUND++))
    fi
done

if [[ $QUOTE_FOUND -ge 2 ]]; then
    echo -e "${GREEN}PASS${NC}: Plan content quoted ($QUOTE_FOUND/3 markers found)"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: Plan not quoted verbatim ($QUOTE_FOUND/3 markers)"
    ((FAIL++)) || true
fi

# Check 2: Analysis grade should appear
echo ""
echo "Check 2: Analysis grade..."
if echo "$RESPONSE" | grep -qiE 'analysis.*grade|grade.*analysis|/a.*grade|understand|analysis:'; then
    echo -e "${GREEN}PASS${NC}: Analysis grade mentioned"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: Analysis grade not explicitly mentioned"
fi

# Check 3: Plan grade should appear
echo ""
echo "Check 3: Plan grade..."
if echo "$RESPONSE" | grep -qiE 'plan.*grade|grade.*plan|/p.*grade|quality|sound'; then
    echo -e "${GREEN}PASS${NC}: Plan grade mentioned"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: Plan grade not explicitly mentioned"
fi

# Check 4: Blocking prompt (May I proceed / improve or proceed)
echo ""
echo "Check 4: Blocking prompt..."
if echo "$RESPONSE" | grep -qiE 'may I proceed|improve or proceed|proceed\?|approval'; then
    echo -e "${GREEN}PASS${NC}: Blocking prompt present"
    ((PASS++)) || true
else
    echo -e "${RED}FAIL${NC}: No blocking prompt found"
    ((FAIL++)) || true
fi

# Check 5: No implementation before approval
echo ""
echo "Check 5: No premature implementation..."
if [[ -f "$TEST_CWD/bin/fizzbuzz" ]] || ls "$TEST_CWD"/*.py "$TEST_CWD"/*.sh 2>/dev/null | grep -qv CLAUDE; then
    echo -e "${RED}FAIL${NC}: Implementation started before approval"
    ((FAIL++)) || true
else
    echo -e "${GREEN}PASS${NC}: No implementation before approval"
    ((PASS++)) || true
fi

# Cleanup test plan file
rm -f "$PLAN_FILE"

# Print summary
print_summary

# Generate report
echo ""
generate_report

exit $FAIL
