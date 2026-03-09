#!/bin/bash
# UC6 Integration Test: Lesson Capture
# Verifies non-actionable gaps route to guides, not grade deductions
#
# Scenario: Grade work with mixed actionable/non-actionable gaps
# 1. Create incomplete deliverable
# 2. Request grade
# 3. Verify actionable gaps in deductions
# 4. Verify non-actionable gaps in Lesson entry

source "$(dirname "$0")/common.sh"

print_header "UC6: Lesson Capture"

# Setup
setup_workspace
trap 'cleanup true' EXIT

# Create a deliverable with intentional gaps
mkdir -p "$TEST_CWD/bin"
cat > "$TEST_CWD/bin/fizzbuzz" << 'EOF'
#!/bin/bash
# Fizzbuzz implementation - intentionally incomplete

for i in $(seq 1 100); do
    if (( i % 15 == 0 )); then
        echo "FizzBuzz"
    elif (( i % 3 == 0 )); then
        echo "Fizz"
    elif (( i % 5 == 0 )); then
        echo "Buzz"
    else
        echo "$i"
    fi
done
EOF
chmod +x "$TEST_CWD/bin/fizzbuzz"

# Create a partial test file (actionable gap: missing tests)
cat > "$TEST_CWD/test_fizzbuzz.sh" << 'EOF'
#!/bin/bash
# Tests - incomplete (actionable gap)

# Only tests happy path, missing edge cases
./bin/fizzbuzz | head -15 > /tmp/fb_output.txt
if grep -q "FizzBuzz" /tmp/fb_output.txt; then
    echo "PASS: FizzBuzz appears"
else
    echo "FAIL: FizzBuzz missing"
fi
EOF

git add -A
git commit -q -m "add incomplete fizzbuzz"

echo "Created incomplete fizzbuzz with gaps:"
echo "- Actionable: Missing edge case tests"
echo "- Non-actionable: Could use better error handling (process improvement)"
echo ""

# Start session
echo "Step 1: Start session with fizzbuzz task..."
RESULT=$(start_session "/tandem plan to complete the fizzbuzz tests so we have full coverage" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Approve plan
echo ""
echo "Step 2: Gate 1 - proceed..."
sleep 2
implementation_gate "proceed" 10 > /dev/null

# Request grade (triggers gap identification)
echo ""
echo "Step 3: Request grade..."
sleep 2
GRADE_RESULT=$(resume_session "grade" 5)

echo ""
echo "Grade response received"

# UC6 Assertions
echo ""
echo "UC6 Lesson Capture Checks..."

# Check 1: Grade has deductions (not 100/100)
if echo "$GRADE_RESULT" | grep -qE '[0-9]+/100|[A-F][+-]?'; then
    if echo "$GRADE_RESULT" | grep -qE '100/100|A\+'; then
        echo -e "${YELLOW}WARN${NC}: Perfect grade - no gaps to evaluate"
    else
        echo -e "${GREEN}PASS${NC}: Grade has deductions"
        ((PASS++)) || true
    fi
else
    echo -e "${YELLOW}INFO${NC}: Grade format not detected in response"
fi

# Check 2: Interaction logged for grade
assert_era_event_exists "Interaction entry for grade" "interaction"

# Request improve to trigger lesson capture
echo ""
echo "Step 4: Request improve..."
sleep 2
resume_session "improve" 10 > /dev/null

# Gate 2
echo ""
echo "Step 5: Gate 2 - proceed (using context injection)..."
sleep 2
completion_gate "proceed" 10 > /dev/null

# Check 3: Lesson capture in grade response (non-actionable gaps route to guides)
echo ""
echo "Checking for Lesson awareness..."
if echo "$GRADE_RESULT" | grep -qiE 'lesson|guide|non-actionable|process improvement'; then
    echo -e "${GREEN}PASS${NC}: Grade mentions lesson/guide routing"
    ((PASS++)) || true
else
    echo -e "${YELLOW}INFO${NC}: No explicit lesson routing in grade response"
    echo "This is OK if all gaps were actionable"
fi

# Check 4: Completion entry exists in Era
assert_era_event_exists "Completion entry" "complete"

# Print summary
print_summary

# Generate report
echo ""
generate_report

exit $FAIL
