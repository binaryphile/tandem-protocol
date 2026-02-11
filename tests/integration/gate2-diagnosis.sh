#!/bin/bash
# Gate 2 Differential Diagnosis Tests
# Tests hypotheses for why Gate 2 bash block execution fails

source "$(dirname "$0")/common.sh"

print_header "Gate 2 Differential Diagnosis"

# Results array
declare -A RESULTS

run_test() {
    local test_name="$1"
    local gate2_prompt="$2"
    local workspace_suffix="$3"

    echo ""
    echo "=== $test_name ==="

    # Setup fresh workspace
    TEST_DIR=$(mktemp -d "/tmp/tandem-diag-$workspace_suffix-XXXXXX")
    TEST_CWD="$TEST_DIR/workspace"
    mkdir -p "$TEST_CWD"
    cd "$TEST_CWD"

    # Create CLAUDE.md with protocol
    echo "# Test Project" > CLAUDE.md
    cat "$PROTOCOL" >> CLAUDE.md

    git init -q
    git add CLAUDE.md
    git commit -q -m "init"
    touch plan-log.md

    echo "Workspace: $TEST_CWD"

    # Step 1: Start session with simple task
    echo "  Starting session..."
    RESULT=$(PROJECT_ROOT="$TEST_CWD" claude -p "/tandem implement a hello.py that prints hello world" \
        --model sonnet \
        --output-format json \
        --max-turns 8 \
        --permission-mode acceptEdits \
        2>/dev/null) || true

    SESSION_ID=$(echo "$RESULT" | jq -r '.session_id // empty' 2>/dev/null)

    if [[ -z "$SESSION_ID" ]]; then
        echo "  ERROR: Failed to start session"
        RESULTS["$test_name"]="ERROR"
        return
    fi

    # Step 2: Gate 1 - proceed
    echo "  Gate 1: proceed..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "proceed" \
        --model sonnet \
        --output-format json \
        --max-turns 5 \
        --permission-mode acceptEdits \
        2>/dev/null > /dev/null || true

    # Check Contract logged (use head -1 to handle multiline edge cases)
    CONTRACT=$(grep -c "Contract:" "$TEST_CWD/plan-log.md" 2>/dev/null | head -1 || echo 0)
    [[ -z "$CONTRACT" ]] && CONTRACT=0
    echo "  Contract entries: $CONTRACT"

    # Step 3: Gate 2 - test specific prompt
    echo "  Gate 2: $test_name..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "$gate2_prompt" \
        --model sonnet \
        --output-format json \
        --max-turns 5 \
        --permission-mode acceptEdits \
        2>/dev/null > /dev/null || true

    # Check Completion logged (use head -1 to handle multiline edge cases)
    COMPLETION=$(grep -c "Completion:" "$TEST_CWD/plan-log.md" 2>/dev/null | head -1 || echo 0)
    [[ -z "$COMPLETION" ]] && COMPLETION=0
    echo "  Completion entries: $COMPLETION"

    if [[ "$COMPLETION" -gt 0 ]]; then
        RESULTS["$test_name"]="SUCCESS ($COMPLETION)"
        echo -e "  ${GREEN}SUCCESS${NC}: Completion logged!"
    else
        RESULTS["$test_name"]="FAIL"
        echo -e "  ${RED}FAIL${NC}: No Completion entry"
    fi

    # Preserve workspace for analysis
    echo "  Logs at: $TEST_DIR"
}

# Test 0: Baseline - just "proceed"
run_test "Baseline" "proceed" "baseline"

# Test 1: Inline block in prompt
INLINE_PROMPT='proceed - execute this completion logging:
```bash
cat >> plan-log.md << '\''EOF'\''
'"$(date -Iseconds)"' | Completion: Hello World
[x] hello.py created (verified)
EOF
```'
run_test "Inline Block" "$INLINE_PROMPT" "inline"

# Test 2: Explicit trigger phrase
run_test "Explicit Trigger" "execute the Gate 2 Completion bash block from the plan file now" "explicit"

# Test 3: Very explicit with action
run_test "Direct Command" "run: cat >> plan-log.md << 'EOF'
$(date -Iseconds) | Completion: Hello World
[x] done (hello.py exists)
EOF" "direct"

# Test 4: Ask Claude to do it
run_test "Instruction" "Log a Completion entry to plan-log.md with timestamp, 'Completion: Hello World', and '[x] hello.py created (verified)'" "instruction"

# Summary
echo ""
echo "============================================"
echo "=== RESULTS ==="
echo "============================================"
for test_name in "${!RESULTS[@]}"; do
    echo "  $test_name: ${RESULTS[$test_name]}"
done

# Return success if any test worked
for result in "${RESULTS[@]}"; do
    if [[ "$result" == SUCCESS* ]]; then
        exit 0
    fi
done
exit 1
