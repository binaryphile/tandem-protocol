#!/bin/bash
# Behavioral Integration Test - Protocol Walk
# Self-contained test that drives through tandem protocol gates and verifies compliance
#
# What it does:
#   1. Installs hooks to capture tool calls
#   2. Starts a session with protocol + fizzbuzz task
#   3. Drives through: Gate 1 → Grade → Improve → Gate 2
#   4. Verifies hooks logged correct tool calls in sequence
#   5. Verifies plan-log.md has correct entries
#
# Requirements:
#   - Claude Code CLI installed
#   - jq installed
#   - Write access to ~/.claude/settings.json (backs up and restores)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROTOCOL="$PROJECT_DIR/README.md"
LOG_DIR="/tmp/tandem-test-$$"
TOOL_LOG="$LOG_DIR/tool-calls.log"
PLAN_LOG="$LOG_DIR/plan-log.md"
SETTINGS_BACKUP="$LOG_DIR/settings-backup.json"

# Cleanup on exit
cleanup() {
    # Restore settings
    if [[ -f "$SETTINGS_BACKUP" ]]; then
        cp "$SETTINGS_BACKUP" ~/.claude/settings.json 2>/dev/null || true
    elif [[ -f ~/.claude/settings.json.tandem-backup ]]; then
        mv ~/.claude/settings.json.tandem-backup ~/.claude/settings.json 2>/dev/null || true
    fi
    # Keep logs for debugging if test failed
    if [[ $TEST_FAILED -eq 0 ]]; then
        rm -rf "$LOG_DIR" 2>/dev/null || true
    else
        echo "Logs preserved at: $LOG_DIR"
    fi
}
trap cleanup EXIT

TEST_FAILED=0
PASS=0
FAIL=0

echo "=== Tandem Protocol Integration Test ==="
echo "Testing: Self-contained protocol walk"
echo ""

# Setup
mkdir -p "$LOG_DIR"
mkdir -p ~/.claude

# Backup existing settings
if [[ -f ~/.claude/settings.json ]]; then
    cp ~/.claude/settings.json "$SETTINGS_BACKUP"
fi

# Install hooks to capture tool calls
cat > ~/.claude/settings.json << 'HOOKS_EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Task.*",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now, tool: .tool_name, input: .tool_input}' >> /tmp/tandem-test-PLACEHOLDER/tool-calls.log"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now, tool: \"Bash\", command: .tool_input.command}' >> /tmp/tandem-test-PLACEHOLDER/tool-calls.log"
          }
        ]
      }
    ]
  }
}
HOOKS_EOF

# Replace placeholder with actual PID
sed -i "s/PLACEHOLDER/$$/g" ~/.claude/settings.json

echo "1. Hooks installed"
echo "2. Starting session..."

# Create test working directory
TEST_CWD="$LOG_DIR/workspace"
mkdir -p "$TEST_CWD"
cd "$TEST_CWD"

# Initialize plan-log.md
touch plan-log.md

# Start session with protocol + fizzbuzz task
# Using --max-turns to prevent runaway, --output-format json for session_id
RESULT=$(cat "$PROTOCOL" | claude -p "/tandem plan to implement fizzbuzz so we verify protocol compliance" \
    --output-format json \
    --max-turns 15 \
    --permission-mode acceptEdits \
    2>/dev/null) || true

SESSION_ID=$(echo "$RESULT" | jq -r '.session_id // empty' 2>/dev/null)

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    echo "Result: $RESULT"
    TEST_FAILED=1
    exit 1
fi

echo "   Session started: $SESSION_ID"
echo "3. Driving through Gate 1..."

# Gate 1: Approve plan
sleep 2
claude --resume "$SESSION_ID" -p "proceed" \
    --output-format json \
    --max-turns 10 \
    --permission-mode acceptEdits \
    2>/dev/null > /dev/null || true

echo "4. Requesting grade..."

# Grade
sleep 2
claude --resume "$SESSION_ID" -p "grade" \
    --output-format json \
    --max-turns 3 \
    --permission-mode acceptEdits \
    2>/dev/null > /dev/null || true

echo "5. Requesting improve..."

# Improve
sleep 2
claude --resume "$SESSION_ID" -p "improve" \
    --output-format json \
    --max-turns 10 \
    --permission-mode acceptEdits \
    2>/dev/null > /dev/null || true

echo "6. Driving through Gate 2..."

# Gate 2: Approve results
sleep 2
claude --resume "$SESSION_ID" -p "proceed" \
    --output-format json \
    --max-turns 10 \
    --permission-mode acceptEdits \
    2>/dev/null > /dev/null || true

echo "7. Verifying compliance..."
echo ""

# Copy plan-log.md from workspace
cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || touch "$PLAN_LOG"

echo "=== TaskAPI Compliance ==="

# T1: TaskCreate calls present
if [[ -f "$TOOL_LOG" ]] && grep -q '"tool":"TaskCreate"' "$TOOL_LOG" 2>/dev/null; then
    echo "PASS: T1 - TaskCreate calls found"
    ((PASS++))
else
    echo "FAIL: T1 - No TaskCreate calls"
    ((FAIL++))
fi

# T2: TaskUpdate with in_progress
if [[ -f "$TOOL_LOG" ]] && grep -q 'in_progress' "$TOOL_LOG" 2>/dev/null; then
    echo "PASS: T2 - TaskUpdate in_progress found"
    ((PASS++))
else
    echo "FAIL: T2 - No TaskUpdate in_progress"
    ((FAIL++))
fi

# T3: TaskUpdate with completed
if [[ -f "$TOOL_LOG" ]] && grep -q 'completed' "$TOOL_LOG" 2>/dev/null; then
    echo "PASS: T3 - TaskUpdate completed found"
    ((PASS++))
else
    echo "FAIL: T3 - No TaskUpdate completed"
    ((FAIL++))
fi

# T4: TaskUpdate with deleted (telescoping)
if [[ -f "$TOOL_LOG" ]] && grep -q 'deleted' "$TOOL_LOG" 2>/dev/null; then
    echo "PASS: T4 - TaskUpdate deleted found (telescoping)"
    ((PASS++))
else
    echo "FAIL: T4 - No TaskUpdate deleted (telescoping)"
    ((FAIL++))
fi

echo ""
echo "=== Logging Compliance ==="

# L1: Contract entry at Gate 1
if grep -qE 'Contract:' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L1 - Contract entry found"
    ((PASS++))
else
    echo "FAIL: L1 - No Contract entry"
    ((FAIL++))
fi

# L2: Contract has criteria checkboxes
if grep -qE 'Contract:.*\[ \]' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L2 - Contract has criteria checkboxes"
    ((PASS++))
else
    echo "FAIL: L2 - Contract missing criteria checkboxes"
    ((FAIL++))
fi

# L3: Completion entry at Gate 2
if grep -qE 'Completion:' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L3 - Completion entry found"
    ((PASS++))
else
    echo "FAIL: L3 - No Completion entry"
    ((FAIL++))
fi

# L4: Completion has evidence
if grep -qE 'Completion:.*\[x\]' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L4 - Completion has filled criteria"
    ((PASS++))
else
    echo "FAIL: L4 - Completion missing filled criteria"
    ((FAIL++))
fi

# L5: Interaction entry for grade
if grep -qE 'Interaction:.*grade' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L5 - Interaction (grade) entry found"
    ((PASS++))
else
    echo "FAIL: L5 - No Interaction (grade) entry"
    ((FAIL++))
fi

# L6: Interaction entry for improve
if grep -qE 'Interaction:.*improve' "$PLAN_LOG" 2>/dev/null; then
    echo "PASS: L6 - Interaction (improve) entry found"
    ((PASS++))
else
    echo "FAIL: L6 - No Interaction (improve) entry"
    ((FAIL++))
fi

echo ""
echo "=== Sequence Compliance ==="

# S1: Contract before Completion (check timestamps)
if [[ -f "$PLAN_LOG" ]]; then
    CONTRACT_LINE=$(grep -n 'Contract:' "$PLAN_LOG" 2>/dev/null | head -1 | cut -d: -f1)
    COMPLETION_LINE=$(grep -n 'Completion:' "$PLAN_LOG" 2>/dev/null | head -1 | cut -d: -f1)

    if [[ -n "$CONTRACT_LINE" && -n "$COMPLETION_LINE" && "$CONTRACT_LINE" -lt "$COMPLETION_LINE" ]]; then
        echo "PASS: S1 - Contract logged before Completion"
        ((PASS++))
    else
        echo "FAIL: S1 - Contract not before Completion (Contract:$CONTRACT_LINE, Completion:$COMPLETION_LINE)"
        ((FAIL++))
    fi
else
    echo "FAIL: S1 - No plan-log.md found"
    ((FAIL++))
fi

# S2: TaskCreate before TaskUpdate
if [[ -f "$TOOL_LOG" ]]; then
    CREATE_LINE=$(grep -n 'TaskCreate' "$TOOL_LOG" 2>/dev/null | head -1 | cut -d: -f1)
    UPDATE_LINE=$(grep -n 'TaskUpdate' "$TOOL_LOG" 2>/dev/null | head -1 | cut -d: -f1)

    if [[ -n "$CREATE_LINE" && -n "$UPDATE_LINE" && "$CREATE_LINE" -lt "$UPDATE_LINE" ]]; then
        echo "PASS: S2 - TaskCreate before TaskUpdate"
        ((PASS++))
    elif [[ -z "$CREATE_LINE" ]]; then
        echo "FAIL: S2 - No TaskCreate found"
        ((FAIL++))
    else
        echo "FAIL: S2 - TaskUpdate before TaskCreate"
        ((FAIL++))
    fi
else
    echo "FAIL: S2 - No tool log found"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [[ $FAIL -gt 0 ]]; then
    TEST_FAILED=1
    echo ""
    echo "Tool log: $TOOL_LOG"
    echo "Plan log: $PLAN_LOG"
fi

exit $FAIL
