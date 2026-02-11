#!/bin/bash
# Gate 2 Differential Diagnosis Tests
# Tests hypotheses for why Gate 2 bash block execution fails
#
# OPTIMIZATION: Uses session branching to run Gate 1 once, then branch for each Gate 2 test
# This reduces test time by ~80% compared to full replay for each test.

source "$(dirname "$0")/common.sh"

print_header "Gate 2 Differential Diagnosis"

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

# Step 1: Run seed session through planning
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

# Step 2: Gate 1 - proceed (creates implementation)
echo "  Gate 1: proceed..."
sleep 2
GATE1_RESULT=$(PROJECT_ROOT="$SEED_CWD" claude --resume "$SEED_SESSION" -p "proceed" \
    --model sonnet \
    --output-format json \
    --max-turns 5 \
    --permission-mode acceptEdits \
    2>/dev/null) || true

# Check Contract logged (grep -c can return multiline, use wc -l on matches instead)
CONTRACT=$(grep "Contract:" "$SEED_CWD/plan-log.md" 2>/dev/null | wc -l || echo 0)
CONTRACT=${CONTRACT//[^0-9]/}  # strip whitespace
[[ -z "$CONTRACT" ]] && CONTRACT=0
echo "  Contract entries: $CONTRACT"

# If seed session didn't produce valid state, abort
if [[ "$CONTRACT" -eq 0 ]] || [[ ! -f "$SEED_CWD/hello.py" ]]; then
    echo "  ERROR: Seed session did not complete Gate 1 properly"
    echo "  Contract: $CONTRACT, hello.py exists: $([[ -f "$SEED_CWD/hello.py" ]] && echo yes || echo no)"
    echo "  This is model variance - try running again"
    exit 1
fi

# Find checkpoint UUID (last message in session = post-Gate 1 state)
SESSION_FILE="$HOME/.claude/projects/-home-ted-projects-tandem-protocol/$SEED_SESSION.jsonl"
if [[ ! -f "$SESSION_FILE" ]]; then
    # Try encoded path
    SESSION_FILE=$(find ~/.claude/projects -name "$SEED_SESSION.jsonl" 2>/dev/null | head -1)
fi

if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
    echo "  ERROR: Cannot find session file for branching"
    echo "  Falling back to full replay mode..."
    # Could fall back to original approach here, but for now just exit
    exit 1
fi

# Get the UUID of the last assistant message (checkpoint for branching)
CHECKPOINT_UUID=$(grep '"type":"assistant"' "$SESSION_FILE" | tail -1 | jq -r '.uuid // empty')

if [[ -z "$CHECKPOINT_UUID" ]]; then
    echo "  ERROR: Cannot find checkpoint UUID"
    exit 1
fi
echo "  Checkpoint UUID: ${CHECKPOINT_UUID:0:8}..."
echo "  Seed session ready for branching"

# Save seed state for reference
cp "$SEED_CWD/plan-log.md" "$SEED_DIR/plan-log-after-gate1.md"
SEED_HELLO_EXISTS=$([[ -f "$SEED_CWD/hello.py" ]] && echo "yes" || echo "no")
echo "  hello.py exists: $SEED_HELLO_EXISTS"

# Function to run a branched test
run_branched_test() {
    local test_name="$1"
    local gate2_prompt="$2"
    local workspace_suffix="$3"

    echo ""
    echo "=== $test_name ==="

    # Create branch workspace (copy seed workspace state)
    local BRANCH_DIR=$(mktemp -d "/tmp/tandem-diag-$workspace_suffix-XXXXXX")
    local BRANCH_CWD="$BRANCH_DIR/workspace"
    cp -r "$SEED_CWD" "$BRANCH_CWD"

    echo "  Workspace: $BRANCH_CWD"
    echo "  Branching from seed session..."

    # Create branched session (pass workspace path as 4th arg)
    BRANCH_SESSION=$("$SCRIPT_DIR/../lib/session-branch.sh" "$SEED_SESSION" "$CHECKPOINT_UUID" "$gate2_prompt" "$BRANCH_CWD" 2>/dev/null | grep "Created branched session:" | awk '{print $NF}')

    if [[ -z "$BRANCH_SESSION" ]]; then
        echo "  ERROR: Failed to create branch"
        RESULTS["$test_name"]="ERROR"
        return
    fi
    echo "  Branch session: ${BRANCH_SESSION:0:8}..."

    # Run Gate 2 with the branched session
    echo "  Gate 2: $test_name..."
    sleep 1
    PROJECT_ROOT="$BRANCH_CWD" claude --resume "$BRANCH_SESSION" \
        --model sonnet \
        --output-format json \
        --max-turns 5 \
        --permission-mode acceptEdits \
        2>/dev/null > /dev/null || true

    # Check Completion logged (use wc -l instead of grep -c to avoid multiline issues)
    local COMPLETION=$(grep "Completion:" "$BRANCH_CWD/plan-log.md" 2>/dev/null | wc -l || echo 0)
    COMPLETION=${COMPLETION//[^0-9]/}  # strip whitespace
    [[ -z "$COMPLETION" ]] && COMPLETION=0
    echo "  Completion entries: $COMPLETION"

    if [[ "$COMPLETION" -gt 0 ]]; then
        RESULTS["$test_name"]="SUCCESS ($COMPLETION)"
        echo -e "  ${GREEN}SUCCESS${NC}: Completion logged!"
    else
        RESULTS["$test_name"]="FAIL"
        echo -e "  ${RED}FAIL${NC}: No Completion entry"
    fi

    echo "  Logs at: $BRANCH_DIR"
}

# Define Gate 2 test prompts
declare -A GATE2_PROMPTS
GATE2_PROMPTS["Baseline"]="proceed"
GATE2_PROMPTS["Inline Block"]='proceed - execute this completion logging:
```bash
cat >> plan-log.md << '\''EOF'\''
'"$(date -Iseconds)"' | Completion: Hello World
[x] hello.py created (verified)
EOF
```'
GATE2_PROMPTS["Explicit Trigger"]="execute the Gate 2 Completion bash block from the plan file now"
GATE2_PROMPTS["Direct Command"]="run: cat >> plan-log.md << 'EOF'
$(date -Iseconds) | Completion: Hello World
[x] done (hello.py exists)
EOF"
GATE2_PROMPTS["Instruction"]="Log a Completion entry to plan-log.md with timestamp, 'Completion: Hello World', and '[x] hello.py created (verified)'"

# Run all branched tests
for test_name in "Baseline" "Inline Block" "Explicit Trigger" "Direct Command" "Instruction"; do
    run_branched_test "$test_name" "${GATE2_PROMPTS[$test_name]}" "${test_name// /-}"
done

# Summary
echo ""
echo "============================================"
echo "=== RESULTS ==="
echo "============================================"
for test_name in "${!RESULTS[@]}"; do
    echo "  $test_name: ${RESULTS[$test_name]}"
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
