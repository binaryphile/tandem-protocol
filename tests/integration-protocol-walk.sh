#!/bin/bash
# Behavioral Integration Test - Protocol Walk with Checkpoint Verification
# Self-contained test that drives through tandem protocol gates and verifies compliance
# BETWEEN each gate (not just final state), enabling compliance curve tracking.
#
# What it does:
#   1. Installs hooks to capture tool calls
#   2. Starts a session with protocol + fizzbuzz task
#   3. CHECKPOINT after each gate: Start → Gate 1 → Grade → Improve → Gate 2
#   4. Verifies timing (no premature actions) and presence (required actions happened)
#   5. Outputs structured JSON for compliance curve tracking
#
# Requirements:
#   - Claude Code CLI installed
#   - jq installed
#   - Write access to ~/.claude/settings.json (backs up and restores)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROTOCOL="$PROJECT_DIR/README.md"
VALIDATORS="$SCRIPT_DIR/lib/validators.sh"

# Source validators for hierarchy checking
if [[ -f "$VALIDATORS" ]]; then
    source "$VALIDATORS"
fi
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

# ============================================================================
# CHECKPOINT VERIFICATION FUNCTIONS
# ============================================================================

# Line count tracking for timing verification
TOOL_LOG_LINES_START=0
TOOL_LOG_LINES_GATE1=0
PLAN_LOG_LINES_START=0
PLAN_LOG_LINES_GATE1=0

get_line_count() {
    local count
    count=$(wc -l < "$1" 2>/dev/null) || count=0
    echo "${count//[[:space:]]/}"
}

checkpoint() {
    local name="$1"
    echo "CHECKPOINT: $name"
}

# Verify expected state at each checkpoint
verify_after_start() {
    local errors=0
    TOOL_LOG_LINES_START=$(get_line_count "$TOOL_LOG")
    PLAN_LOG_LINES_START=$(get_line_count "$PLAN_LOG")

    # Contract should NOT exist yet
    if grep -qE 'Contract:' "$PLAN_LOG" 2>/dev/null; then
        echo "  FAIL: No Contract yet (TIMING VIOLATION)"
        ((errors++))
    else
        echo "  PASS: No Contract yet"
    fi
    # TaskCreate should NOT exist yet
    if grep -q '"tool":"TaskCreate"' "$TOOL_LOG" 2>/dev/null; then
        echo "  FAIL: No TaskCreate yet (TIMING VIOLATION)"
        ((errors++))
    else
        echo "  PASS: No TaskCreate yet"
    fi
    return $errors
}

verify_after_gate1() {
    local errors=0
    TOOL_LOG_LINES_GATE1=$(get_line_count "$TOOL_LOG")
    PLAN_LOG_LINES_GATE1=$(get_line_count "$PLAN_LOG")

    # Contract MUST exist with UC7 format: "Contract: [phase] | [ ] criterion1, [ ] criterion2"
    if grep -qE 'Contract:.*\|.*\[ \].*,' "$PLAN_LOG" 2>/dev/null; then
        echo "  PASS: Contract entry with criteria (UC7 format)"
    else
        echo "  FAIL: Contract entry with criteria (UC7 format)"
        ((errors++))
    fi
    # Task tracking: Plan file checkboxes required, TaskAPI is bonus
    local task_creates plan_tasks
    task_creates=$(grep -c '"tool":"TaskCreate"' "$TOOL_LOG" 2>/dev/null | tr -d '[:space:]')
    task_creates=${task_creates:-0}
    # Check for plan file task checkboxes ([ ] or [x] or [in_progress])
    plan_tasks=$(grep -cE '\[ \]|\[x\]|\[in_progress\]' "$TEST_CWD"/*.md 2>/dev/null | tr -d '[:space:]')
    plan_tasks=${plan_tasks:-0}
    # Plan file is required
    if [[ ${plan_tasks:-0} -gt 0 ]]; then
        echo "  PASS: Tasks recorded in plan file (required)"
    else
        echo "  FAIL: Tasks not recorded in plan file"
        ((errors++))
    fi
    # TaskAPI is bonus (report but don't fail)
    if [[ ${task_creates:-0} -gt 0 ]]; then
        echo "  BONUS: TaskCreate also called (spinner UI)"
    else
        echo "  INFO: TaskCreate not called (expected - variable compliance)"
    fi
    # Task active: plan file checkbox sufficient
    if grep -qE '\[in_progress\]|\[ \]' "$TEST_CWD"/*.md 2>/dev/null; then
        echo "  PASS: Tasks visible in plan file"
    else
        echo "  FAIL: No tasks in plan file"
        ((errors++))
    fi
    return $errors
}

verify_after_grade() {
    local errors=0
    # UC7 format: "Interaction: [input] → [response]" (arrow required)
    if grep -qE 'Interaction:.*grade.*->' "$PLAN_LOG" 2>/dev/null; then
        echo "  PASS: Interaction entry for grade (UC7 format)"
    else
        echo "  FAIL: Interaction entry for grade (UC7 format)"
        ((errors++))
    fi
    return $errors
}

verify_after_improve() {
    local errors=0
    # Check for second Interaction entry with UC7 arrow format
    local count
    count=$(grep -cE 'Interaction:.*->' "$PLAN_LOG" 2>/dev/null | tr -d '[:space:]')
    count=${count:-0}
    if [[ $count -ge 2 ]]; then
        echo "  PASS: Interaction entry for improve ($count with UC7 format)"
    else
        echo "  FAIL: Interaction entry for improve ($count < 2 with UC7 format)"
        ((errors++))
    fi
    # Task progress: Plan file [x] required, TaskAPI is bonus
    if grep -qE '\[x\]' "$TEST_CWD"/*.md 2>/dev/null; then
        echo "  PASS: Task marked complete in plan file (required)"
    else
        echo "  FAIL: Task not marked complete in plan file"
        ((errors++))
    fi
    # TaskAPI bonus
    if grep -q '"completed"' "$TOOL_LOG" 2>/dev/null; then
        echo "  BONUS: TaskUpdate completed also called"
    else
        echo "  INFO: TaskUpdate completed not called (expected)"
    fi
    return $errors
}

verify_after_gate2() {
    local errors=0
    # UC7: Completion with evidence format "[x] criterion (evidence)" - must have actual content in parens
    if grep -qE 'Completion:.*\[x\].*\([^)]+\)' "$PLAN_LOG" 2>/dev/null; then
        echo "  PASS: Completion entry with evidence (UC7 format)"
    else
        echo "  FAIL: Completion entry with evidence (UC7 format)"
        ((errors++))
    fi
    # Task cleanup: EITHER TaskUpdate deleted OR phase collapsed in plan (intent: phase tasks cleared)
    # Plan file collapse means completed phase has no child tasks visible
    if grep -q '"deleted"' "$TOOL_LOG" 2>/dev/null; then
        echo "  PASS: Phase tasks cleared (Tasks API deleted)"
    else
        # For plan file, we just check that tasks were marked done - full collapse is optional
        echo "  INFO: Tasks API not used for cleanup (plan file is source of truth)"
    fi
    # UC6: Lesson entry - grade/improve cycles should capture non-actionable insights
    # This is a soft requirement: if grade found gaps but no Lesson logged, it's a miss
    local grade_count
    grade_count=$(grep -cE 'Interaction:.*grade.*->' "$PLAN_LOG" 2>/dev/null | tr -d '[:space:]')
    grade_count=${grade_count:-0}
    if grep -qE 'Lesson:.*->' "$PLAN_LOG" 2>/dev/null; then
        echo "  PASS: Lesson entry routed (UC6)"
    elif [[ $grade_count -gt 0 ]]; then
        echo "  WARN: Grade occurred but no Lesson captured (UC6 gap)"
    else
        echo "  PASS: No Lesson needed (no grading gaps)"
    fi
    return $errors
}

verify_plan_hierarchy() {
    local errors=0
    # UC8: After Gate 2, completed phases should be collapsed (no child tasks)
    # Check plan files in workspace and ~/.claude/plans/
    local plan_files=()
    for f in "$TEST_CWD"/*.md ~/.claude/plans/*.md 2>/dev/null; do
        [[ -f "$f" ]] && plan_files+=("$f")
    done

    if [[ ${#plan_files[@]} -eq 0 ]]; then
        echo "  INFO: No plan files found (UC8 check skipped)"
        return 0
    fi

    # Only check if validators are available
    if ! type validate_plan_hierarchy &>/dev/null; then
        echo "  INFO: Validators not loaded, skipping hierarchy check"
        return 0
    fi

    for plan_file in "${plan_files[@]}"; do
        # Skip files that don't look like protocol plan files
        if ! grep -qE '^\[.\] Phase' "$plan_file" 2>/dev/null; then
            continue
        fi
        local result
        result=$(validate_plan_hierarchy "$plan_file" 2>&1)
        if [[ $? -eq 0 ]]; then
            echo "  PASS: Plan hierarchy valid (UC8): $(basename "$plan_file")"
        else
            echo "  WARN: Plan hierarchy issue (UC8): $result"
            # Don't fail - this is aspirational, not blocking
        fi
    done
    return $errors
}

verify_isolation() {
    local errors=0
    # Check if any files leaked to real project
    if [[ -f "$PROJECT_DIR/bin/fizzbuzz" ]]; then
        echo "  FAIL: Isolation - bin/fizzbuzz created in real project"
        ((errors++))
    else
        echo "  PASS: Isolation - no files leaked to real project"
    fi
    # Check that files were created in workspace
    if ls "$TEST_CWD"/*.sh "$TEST_CWD"/bin/* 2>/dev/null | grep -q .; then
        echo "  PASS: Files created in workspace"
    else
        echo "  INFO: No deliverables in workspace (may be OK if test failed early)"
    fi
    return $errors
}

# Graceful handling for complete non-compliance
handle_session_failure() {
    echo "ERROR: Session failed or Claude completely non-compliant"
    echo "  - Check if protocol was in context"
    echo "  - Check if task was understood"
    # Still generate JSON with max errors for curve tracking
    ERRORS_START=${ERRORS_START:-2}
    ERRORS_GATE1=${ERRORS_GATE1:-3}
    ERRORS_GRADE=${ERRORS_GRADE:-1}
    ERRORS_IMPROVE=${ERRORS_IMPROVE:-1}
    ERRORS_GATE2=${ERRORS_GATE2:-2}
}

# ============================================================================
# TEST SETUP
# ============================================================================

echo "=== Tandem Protocol Integration Test ==="
echo "Testing: Checkpoint verification between gates"
echo ""

# Setup
mkdir -p "$LOG_DIR"
mkdir -p ~/.claude

# Clear tool log before installing hooks (fresh start for this trial)
rm -f "$TOOL_LOG"
touch "$TOOL_LOG"

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

# Create isolated workspace with CLAUDE.md (so Claude treats this as project root)
TEST_CWD="$LOG_DIR/workspace"
mkdir -p "$TEST_CWD"
cd "$TEST_CWD"

# Embed protocol in CLAUDE.md (no @reference - self-contained)
echo "# Test Project" > "$TEST_CWD/CLAUDE.md"
cat "$PROTOCOL" >> "$TEST_CWD/CLAUDE.md"

# Initialize git repo (Claude uses git root to determine project)
git init -q
git add CLAUDE.md
git commit -q -m "init"

# Initialize plan-log.md
touch plan-log.md

# ============================================================================
# PROTOCOL WALK WITH CHECKPOINTS
# ============================================================================

# Start session - CLAUDE.md provides protocol context (no piping)
# Override PROJECT_ROOT so nix wrapper doesn't cd back to real project
PROJECT_ROOT="$TEST_CWD" RESULT=$(claude -p "/tandem plan to implement fizzbuzz so we verify protocol compliance" \
    --output-format json \
    --max-turns 15 \
    --permission-mode acceptEdits \
    2>/dev/null) || true

SESSION_ID=$(echo "$RESULT" | jq -r '.session_id // empty' 2>/dev/null)

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    echo "Result: $RESULT"
    handle_session_failure
else
    echo "   Session started: $SESSION_ID"

    # Disable set -e for verification section (we want to capture errors, not exit)
    set +e

    # CHECKPOINT 1: After start, before Gate 1
    checkpoint "After session start"
    cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || touch "$PLAN_LOG"
    verify_after_start
    ERRORS_START=$?

    # Gate 1: Approve plan
    echo "3. Driving through Gate 1..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "proceed" \
        --output-format json --max-turns 10 --permission-mode acceptEdits 2>/dev/null > /dev/null || true

    # CHECKPOINT 2: After Gate 1
    checkpoint "After Gate 1 (proceed)"
    cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || true
    verify_after_gate1
    ERRORS_GATE1=$?

    # Grade
    echo "4. Requesting grade..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "grade" \
        --output-format json --max-turns 3 --permission-mode acceptEdits 2>/dev/null > /dev/null || true

    # CHECKPOINT 3: After grade
    checkpoint "After grade"
    cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || true
    verify_after_grade
    ERRORS_GRADE=$?

    # Improve
    echo "5. Requesting improve..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "improve" \
        --output-format json --max-turns 10 --permission-mode acceptEdits 2>/dev/null > /dev/null || true

    # CHECKPOINT 4: After improve
    checkpoint "After improve"
    cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || true
    verify_after_improve
    ERRORS_IMPROVE=$?

    # Gate 2: Approve results
    echo "6. Driving through Gate 2..."
    sleep 2
    PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "proceed" \
        --output-format json --max-turns 10 --permission-mode acceptEdits 2>/dev/null > /dev/null || true

    # CHECKPOINT 5: After Gate 2
    checkpoint "After Gate 2 (proceed)"
    cp "$TEST_CWD/plan-log.md" "$PLAN_LOG" 2>/dev/null || true
    verify_after_gate2
    ERRORS_GATE2=$?

    # CHECKPOINT 5b: Plan hierarchy (UC8)
    checkpoint "Plan hierarchy (UC8)"
    verify_plan_hierarchy
    ERRORS_HIERARCHY=$?

    # CHECKPOINT 6: Isolation
    checkpoint "Isolation"
    verify_isolation
    ERRORS_ISOLATION=$?

    # Re-enable set -e
    set -e
fi

# ============================================================================
# GENERATE COMPLIANCE JSON
# ============================================================================

ERRORS_ISOLATION=${ERRORS_ISOLATION:-0}
ERRORS_HIERARCHY=${ERRORS_HIERARCHY:-0}
TOTAL_CHECKS=11  # 2+3+1+2+2+1 checks, minus 1 (gate2 task cleanup now INFO not FAIL)
TOTAL_ERRORS=$((ERRORS_START + ERRORS_GATE1 + ERRORS_GRADE + ERRORS_IMPROVE + ERRORS_GATE2 + ERRORS_HIERARCHY + ERRORS_ISOLATION))
SCORE=$((TOTAL_CHECKS - TOTAL_ERRORS))

# Helper for safe boolean checks (handles missing files)
check_exists() { grep -q "$1" "$2" 2>/dev/null && echo true || echo false; }
check_count() { local c; c=$(grep -c "$1" "$2" 2>/dev/null | tr -d '[:space:]'); c=${c:-0}; [[ $c -ge $3 ]] && echo true || echo false; }
# Check for task tracking in either mechanism
check_task_tracking() {
    grep -q '"tool":"TaskCreate"' "$TOOL_LOG" 2>/dev/null && echo "tasks_api" && return
    grep -qE '\[ \]|\[x\]' "$TEST_CWD"/*.md 2>/dev/null && echo "plan_file" && return
    echo "none"
}

cat > "$LOG_DIR/compliance.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "session_id": "$SESSION_ID",
  "checkpoints": {
    "start": {"errors": $ERRORS_START, "timing_ok": $([[ $ERRORS_START -eq 0 ]] && echo true || echo false)},
    "gate1": {"errors": $ERRORS_GATE1, "contract_uc7": $(check_exists 'Contract:.*|.*\[ \]' "$PLAN_LOG"), "task_tracking": "$(check_task_tracking)"},
    "grade": {"errors": $ERRORS_GRADE, "interaction_uc7": $(check_exists 'Interaction:.*->' "$PLAN_LOG")},
    "improve": {"errors": $ERRORS_IMPROVE, "interaction_count": $(c=$(grep -c 'Interaction:.*->' "$PLAN_LOG" 2>/dev/null | tr -d '[:space:]'); echo ${c:-0}), "task_complete": $(check_exists 'completed\|\\[x\\]' "$TOOL_LOG" "$TEST_CWD"/*.md)},
    "gate2": {"errors": $ERRORS_GATE2, "completion_uc7": $(check_exists 'Completion:.*\[x\].*([^)]+)' "$PLAN_LOG"), "lesson_uc6": $(check_exists 'Lesson:.*->' "$PLAN_LOG")},
    "hierarchy": {"errors": $ERRORS_HIERARCHY, "uc8_checked": $([[ -f "$VALIDATORS" ]] && echo true || echo false)},
    "isolation": {"errors": $ERRORS_ISOLATION, "no_leak": $([[ ! -f "$PROJECT_DIR/bin/fizzbuzz" ]] && echo true || echo false)}
  },
  "score": $SCORE,
  "max_score": $TOTAL_CHECKS
}
EOF

echo ""
echo "=== Compliance Summary ==="
echo "Score: $SCORE/$TOTAL_CHECKS"
cat "$LOG_DIR/compliance.json" | jq -c '.checkpoints'

if [[ $TOTAL_ERRORS -gt 0 ]]; then
    TEST_FAILED=1
    echo ""
    echo "Tool log: $TOOL_LOG"
    echo "Plan log: $PLAN_LOG"
    echo "Compliance JSON: $LOG_DIR/compliance.json"
fi

exit $TOTAL_ERRORS
