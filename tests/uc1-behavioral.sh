#!/bin/bash
# UC1 Behavioral Test: Step 1b Sequencing
# Tests that Claude ASKS questions rather than embedding them
#
# Methodology: /q cuing + output pattern testing per behavioral testing guide
# Cuing: Uses "/q Step 1b" to invoke protocol step quotation
# Success: Claude asks questions in output (contains "?" or "clarif" keywords)
# Failure: Claude proceeds without asking OR embeds questions in plan

set -u

PROTOCOL="../tandem-protocol.md"
# Fresh directory per test run
TEST_RUN_ID="uc1-$$-$(date +%s)"
TEST_DIR="/tmp/$TEST_RUN_ID"
SCENARIO_DIR="$TEST_DIR/scenarios"
OUTPUT_DIR="$TEST_DIR/output"
TRIALS=3
PASSED=0
FAILED=0

# Setup - fresh directory
rm -rf "$TEST_DIR"
mkdir -p "$SCENARIO_DIR" "$OUTPUT_DIR"
echo "Test directory: $TEST_DIR"

# Create test scenario: Ambiguous task that SHOULD trigger questions
cat > "$SCENARIO_DIR/scenario1.md" << 'SCENARIO_EOF'
User request: "Add authentication to the app"

/q Step 1b

Execute Step 1b now. The task is ambiguous - authentication has multiple approaches.
SCENARIO_EOF

echo "=== UC1 Behavioral Test: Step 1b Sequencing ==="
echo "Testing: Does Claude ASK questions rather than embed them?"
echo "Trials: $TRIALS"
echo ""

# Run trials
for i in $(seq 1 $TRIALS); do
    OUTPUT_FILE="$OUTPUT_DIR/trial-$i.txt"

    echo "--- Trial $i ---"

    # Inject protocol + scenario via stdin (simulates CLAUDE.md)
    # Use --max-turns 2 to detect if Claude wastes turns on file reading
    timeout 120 cat "$PROTOCOL" "$SCENARIO_DIR/scenario1.md" | \
        claude -p --model sonnet --max-turns 3 > "$OUTPUT_FILE" 2>&1

    EXIT_CODE=$?

    # Check for success pattern: questions asked in output
    # Pattern: question marks, "clarif", "question", or AskUserQuestion indicators
    if grep -qiE '\?|clarif|question|what.*would|which.*prefer|could you' "$OUTPUT_FILE"; then
        # Additional check: NOT just proceeding with assumptions
        if grep -qiE 'assuming|I will proceed|let me create' "$OUTPUT_FILE"; then
            # Found both questions AND proceeding language - check which dominates
            Q_COUNT=$(grep -ciE '\?' "$OUTPUT_FILE" || echo 0)
            if [ "$Q_COUNT" -ge 2 ]; then
                echo "PASS: Asked $Q_COUNT questions"
                ((PASSED++))
            else
                echo "FAIL: Made assumptions despite ambiguity"
                ((FAILED++))
            fi
        else
            echo "PASS: Asked clarifying questions"
            ((PASSED++))
        fi
    else
        echo "FAIL: No questions asked"
        echo "  Output preview: $(head -c 200 "$OUTPUT_FILE")"
        ((FAILED++))
    fi

    # Small delay between trials
    sleep 1
done

echo ""
echo "=== Results ==="
echo "Passed: $PASSED/$TRIALS"
echo "Failed: $FAILED/$TRIALS"

RATE=$((PASSED * 100 / TRIALS))
echo "Success rate: $RATE%"

echo ""
echo "=== Experiment 2: Clear task - should state 'no questions' ==="

# Create clear task scenario
cat > "$SCENARIO_DIR/scenario2.md" << 'SCENARIO_EOF'
User request: "Fix the typo on line 42 of README.md - change 'teh' to 'the'"

/q Step 1b

Execute Step 1b now. This task is clear and unambiguous.
SCENARIO_EOF

PASSED2=0
FAILED2=0

for i in $(seq 1 $TRIALS); do
    OUTPUT_FILE="$OUTPUT_DIR/trial-exp2-$i.txt"

    echo "--- Trial $i ---"

    timeout 120 cat "$PROTOCOL" "$SCENARIO_DIR/scenario2.md" | \
        claude -p --model sonnet --max-turns 3 > "$OUTPUT_FILE" 2>&1

    # Success: explicit "no questions" statement or clear indication task is understood
    if grep -qiE 'no clarifying|no questions|understanding is complete|straightforward|no ambiguit|clear task|simple|ready to proceed|can proceed|will proceed' "$OUTPUT_FILE"; then
        echo "PASS: Explicitly stated no questions needed"
        ((PASSED2++))
    else
        # Check if it asked unnecessary questions
        if grep -qiE '\?' "$OUTPUT_FILE"; then
            echo "FAIL: Asked unnecessary questions for clear task"
        else
            echo "FAIL: Proceeded without explicit 'no questions' statement"
        fi
        ((FAILED2++))
    fi

    sleep 1
done

echo ""
echo "=== Experiment 2 Results ==="
echo "Passed: $PASSED2/$TRIALS"
RATE2=$((PASSED2 * 100 / TRIALS))
echo "Success rate: $RATE2%"

echo ""
echo "=== Overall Verdict ==="
TOTAL_PASSED=$((PASSED + PASSED2))
TOTAL_TRIALS=$((TRIALS * 2))
TOTAL_RATE=$((TOTAL_PASSED * 100 / TOTAL_TRIALS))
echo "Combined: $TOTAL_PASSED/$TOTAL_TRIALS ($TOTAL_RATE%)"

if [ $TOTAL_RATE -ge 67 ]; then
    echo "VERDICT: PASS"
    exit 0
else
    echo "VERDICT: FAIL"
    exit 1
fi
