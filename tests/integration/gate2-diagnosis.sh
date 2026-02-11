#!/bin/bash
# Gate 2 Differential Diagnosis Tests - v2 (Context Injection)
# Tests hypotheses for why Gate 2 bash block execution fails
#
# APPROACH: Run seed session through Gate 1 once, then inject context
# into fresh sessions for each Gate 2 test variant.

source "$(dirname "$0")/common.sh"

print_header "Gate 2 Differential Diagnosis (v2)"

# Results array
declare -A RESULTS

# Setup shared workspace for seed session
SEED_DIR=$(mktemp -d "/tmp/tandem-diag-seed-XXXXXX")
SEED_CWD="$SEED_DIR/workspace"
mkdir -p "$SEED_CWD"
cd "$SEED_CWD"

# Create CLAUDE.md with protocol
echo "# Test Project" > CLAUDE.md
cat "$PROTOCOL" >> CLAUDE.md

git init -q
git add CLAUDE.md
git commit -q -m "init"
touch plan-log.md

echo "Seed workspace: $SEED_CWD"

# Step 1: Run seed session through planning and Gate 1
echo ""
echo "=== Creating Seed Session ==="
echo "  Starting session..."
SEED_RESULT=$(PROJECT_ROOT="$SEED_CWD" claude -p "/tandem implement a hello.py that prints hello world" \
    --model sonnet \
    --output-format json \
    --max-turns 8 \
    --permission-mode acceptEdits \
    2>/dev/null) || true

SEED_SESSION=$(echo "$SEED_RESULT" | jq -r '.session_id // empty' 2>/dev/null)

if [[ -z "$SEED_SESSION" ]]; then
    echo "  ERROR: Failed to start seed session"
    exit 1
fi
echo "  Session: $SEED_SESSION"

# Step 2: Gate 1 - proceed
echo "  Gate 1: proceed..."
sleep 2
PROJECT_ROOT="$SEED_CWD" claude --resume "$SEED_SESSION" -p "proceed" \
    --model sonnet \
    --output-format json \
    --max-turns 10 \
    --permission-mode acceptEdits \
    2>/dev/null > /dev/null || true

# Validate seed session completed Gate 1
CONTRACT=$(grep "Contract:" "$SEED_CWD/plan-log.md" 2>/dev/null | wc -l || echo 0)
CONTRACT=${CONTRACT//[^0-9]/}
[[ -z "$CONTRACT" ]] && CONTRACT=0
echo "  Contract entries: $CONTRACT"

if [[ "$CONTRACT" -eq 0 ]] || [[ ! -f "$SEED_CWD/hello.py" ]]; then
    echo "  ERROR: Seed session did not complete Gate 1 properly"
    echo "  Contract: $CONTRACT, hello.py exists: $([[ -f "$SEED_CWD/hello.py" ]] && echo yes || echo no)"
    echo "  This is model variance - try running again"
    exit 1
fi

# Capture state for context injection
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
PLAN_CONTENT=""
if [[ -f "$PLAN_FILE" ]]; then
    PLAN_CONTENT=$(cat "$PLAN_FILE")
fi
PLANLOG_CONTENT=$(cat "$SEED_CWD/plan-log.md")
HELLO_PY=$(cat "$SEED_CWD/hello.py" 2>/dev/null || echo "")

echo "  Plan file: ${PLAN_FILE:-none}"
echo "  hello.py exists: yes"
echo "  Seed state captured"

# Function to run a context-injected test
run_context_test() {
    local test_name="$1"
    local gate2_prompt="$2"
    local workspace_suffix="$3"

    echo ""
    echo "=== $test_name ==="

    # Create fresh workspace (copy seed state)
    local TEST_DIR=$(mktemp -d "/tmp/tandem-diag-$workspace_suffix-XXXXXX")
    local TEST_CWD="$TEST_DIR/workspace"
    cp -r "$SEED_CWD" "$TEST_CWD"

    echo "  Workspace: $TEST_CWD"

    # Build context prompt
    local CONTEXT="You are in a tandem protocol session. Here's the current state:

## Current State
- We just completed Gate 1 (Implementation Gate)
- hello.py was created successfully
- Contract was logged to plan-log.md

## plan-log.md contents:
$PLANLOG_CONTENT

## hello.py contents:
$HELLO_PY

## Plan file (at $PLAN_FILE):
$PLAN_CONTENT

## What just happened:
You presented the implementation results and asked 'May I proceed?'

## User's response:
$gate2_prompt"

    # Run fresh session with context
    echo "  Running Gate 2 test..."
    PROJECT_ROOT="$TEST_CWD" claude -p "$CONTEXT" \
        --model sonnet \
        --output-format json \
        --max-turns 5 \
        --permission-mode acceptEdits \
        2>/dev/null > /dev/null || true

    # Check Completion logged
    local COMPLETION=$(grep "Completion:" "$TEST_CWD/plan-log.md" 2>/dev/null | wc -l || echo 0)
    COMPLETION=${COMPLETION//[^0-9]/}
    [[ -z "$COMPLETION" ]] && COMPLETION=0
    echo "  Completion entries: $COMPLETION"

    if [[ "$COMPLETION" -gt 0 ]]; then
        RESULTS["$test_name"]="SUCCESS ($COMPLETION)"
        echo -e "  ${GREEN}SUCCESS${NC}: Completion logged!"
    else
        RESULTS["$test_name"]="FAIL"
        echo -e "  ${RED}FAIL${NC}: No Completion entry"
    fi

    echo "  Logs at: $TEST_DIR"
}

# Define Gate 2 test prompts
echo ""
echo "=== Running Gate 2 Tests ==="

# Test 0: Baseline - just "proceed"
run_context_test "Baseline" "proceed" "baseline"

# Test 1: Inline block
INLINE_PROMPT='proceed - execute this completion logging:
```bash
cat >> plan-log.md << '\''EOF'\''
'"$(date -Iseconds)"' | Completion: Hello World
[x] hello.py created (verified)
EOF
```'
run_context_test "Inline Block" "$INLINE_PROMPT" "inline"

# Test 2: Explicit trigger phrase
run_context_test "Explicit Trigger" "execute the Completion Gate bash block from the plan file now" "explicit"

# Test 3: Direct command
run_context_test "Direct Command" "run: cat >> plan-log.md << 'EOF'
$(date -Iseconds) | Completion: Hello World
[x] done (hello.py exists)
EOF" "direct"

# Test 4: Instruction
run_context_test "Instruction" "Log a Completion entry to plan-log.md with timestamp, 'Completion: Hello World', and '[x] hello.py created (verified)'" "instruction"

# Summary
echo ""
echo "============================================"
echo "=== RESULTS ==="
echo "============================================"
for test_name in "Baseline" "Inline Block" "Explicit Trigger" "Direct Command" "Instruction"; do
    echo "  $test_name: ${RESULTS[$test_name]:-SKIPPED}"
done

echo ""
echo "Seed workspace preserved at: $SEED_DIR"

# Return success if any test worked
for result in "${RESULTS[@]}"; do
    if [[ "$result" == SUCCESS* ]]; then
        exit 0
    fi
done
exit 1
