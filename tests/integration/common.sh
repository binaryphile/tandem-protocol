#!/bin/bash
# Common functions for Tandem Protocol integration tests
# Source this file in each test: source "$(dirname "$0")/common.sh"

set -uo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROTOCOL="$PROJECT_DIR/README.md"
VALIDATORS="$PROJECT_DIR/tests/lib/validators.sh"

# Test state
TEST_DIR=""
TEST_CWD=""
SESSION_ID=""
PASS=0
FAIL=0
TEST_NAME=""
LAST_TURNS=0
TOTAL_COST=0

# Colors (if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' NC=''
fi

# ============================================================================
# SETUP / TEARDOWN
# ============================================================================

setup_workspace() {
    TEST_DIR=$(mktemp -d "/tmp/tandem-test-XXXXXX")
    TEST_CWD="$TEST_DIR/workspace"
    mkdir -p "$TEST_CWD"
    cd "$TEST_CWD"

    # Create CLAUDE.md with protocol
    echo "# Test Project" > CLAUDE.md
    cat "$PROTOCOL" >> CLAUDE.md

    # Initialize git repo
    git init -q
    git add CLAUDE.md
    git commit -q -m "init"

    # Initialize plan-log.md
    touch plan-log.md

    echo "Workspace: $TEST_CWD"
}

cleanup() {
    local keep_on_fail="${1:-false}"
    if [[ "$keep_on_fail" == "true" && $FAIL -gt 0 ]]; then
        echo "Logs preserved at: $TEST_DIR"
    else
        rm -rf "$TEST_DIR" 2>/dev/null || true
    fi
}

# ============================================================================
# CLAUDE INTERACTION
# ============================================================================

# Start a new session with a prompt
# Usage: RESULT=$(start_session "prompt" [max_turns])
# Sets: SESSION_ID, LAST_TURNS, TOTAL_COST
# Uses --model sonnet for production verisimilitude per behavioral testing guide
start_session() {
    local prompt="$1"
    local max_turns="${2:-10}"
    local result

    result=$(PROJECT_ROOT="$TEST_CWD" claude -p "$prompt" \
        --model sonnet \
        --output-format json \
        --max-turns "$max_turns" \
        --permission-mode acceptEdits \
        2>/dev/null) || true

    # Extract metrics and set global variables
    # Note: Caller should also extract SESSION_ID from result if needed in subshell
    SESSION_ID=$(echo "$result" | jq -r '.session_id // empty' 2>/dev/null)
    LAST_TURNS=$(echo "$result" | jq -r '.num_turns // 0' 2>/dev/null)
    local cost=$(echo "$result" | jq -r '.total_cost_usd // 0' 2>/dev/null)
    TOTAL_COST=$(echo "$TOTAL_COST + $cost" | bc 2>/dev/null || echo "$TOTAL_COST")

    # Return the full result for callers that capture it
    echo "$result"
}

# Helper to extract session_id from a result (use after capturing start_session output)
# Usage: SESSION_ID=$(extract_session_id "$RESULT")
extract_session_id() {
    echo "$1" | jq -r '.session_id // empty' 2>/dev/null
}

# Resume session with a prompt
# Usage: resume_session "prompt" [max_turns]
# Uses --model sonnet for production verisimilitude per behavioral testing guide
resume_session() {
    local prompt="$1"
    local max_turns="${2:-10}"
    local result

    if [[ -z "$SESSION_ID" ]]; then
        echo "ERROR: No session to resume"
        return 1
    fi

    result=$(PROJECT_ROOT="$TEST_CWD" claude --resume "$SESSION_ID" -p "$prompt" \
        --model sonnet \
        --output-format json \
        --max-turns "$max_turns" \
        --permission-mode acceptEdits \
        2>/dev/null) || true

    LAST_TURNS=$(echo "$result" | jq -r '.num_turns // 0' 2>/dev/null)
    local cost=$(echo "$result" | jq -r '.total_cost_usd // 0' 2>/dev/null)
    TOTAL_COST=$(echo "$TOTAL_COST + $cost" | bc 2>/dev/null || echo "$TOTAL_COST")
    echo "$result"
}

# ============================================================================
# ASSERTIONS
# ============================================================================

# Check if pattern exists in file
# Usage: assert_exists "test name" "pattern" "file"
assert_exists() {
    local name="$1" pattern="$2" file="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}: $name"
        ((PASS++)) || true
        return 0
    else
        echo -e "${RED}FAIL${NC}: $name (pattern '$pattern' not found in $file)"
        ((FAIL++)) || true
        return 1
    fi
}

# Check if pattern does NOT exist in file
# Usage: assert_not_exists "test name" "pattern" "file"
assert_not_exists() {
    local name="$1" pattern="$2" file="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        echo -e "${RED}FAIL${NC}: $name (pattern '$pattern' found but should not exist)"
        ((FAIL++)) || true
        return 1
    else
        echo -e "${GREEN}PASS${NC}: $name"
        ((PASS++)) || true
        return 0
    fi
}

# Check count of pattern matches
# Usage: assert_count "test name" "pattern" "file" min_count [max_count]
assert_count() {
    local name="$1" pattern="$2" file="$3" min="$4" max="${5:-999999}"
    local count

    count=$(grep -cE "$pattern" "$file" 2>/dev/null) || count=0

    if [[ $count -ge $min && $count -le $max ]]; then
        echo -e "${GREEN}PASS${NC}: $name (count=$count, expected $min-$max)"
        ((PASS++)) || true
        return 0
    else
        echo -e "${RED}FAIL${NC}: $name (count=$count, expected $min-$max)"
        ((FAIL++)) || true
        return 1
    fi
}

# Check if string contains substring (for output checking)
# Usage: assert_contains "test name" "output" "substring"
assert_contains() {
    local name="$1" output="$2" substring="$3"

    if [[ "$output" == *"$substring"* ]]; then
        echo -e "${GREEN}PASS${NC}: $name"
        ((PASS++)) || true
        return 0
    else
        echo -e "${RED}FAIL${NC}: $name (substring '$substring' not found)"
        ((FAIL++)) || true
        return 1
    fi
}

# Check validator function passes
# Usage: assert_valid "test name" validator_function args...
assert_valid() {
    local name="$1"
    shift
    local result

    if [[ -f "$VALIDATORS" ]]; then
        source "$VALIDATORS"
    fi

    result=$("$@" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}PASS${NC}: $name"
        ((PASS++)) || true
        return 0
    else
        echo -e "${RED}FAIL${NC}: $name ($result)"
        ((FAIL++)) || true
        return 1
    fi
}

# Check turn usage didn't exceed expected (detects turn exhaustion)
# Usage: assert_turns "test name" expected_max
assert_turns() {
    local name="$1"
    local expected_max="$2"

    if [[ $LAST_TURNS -le $expected_max ]]; then
        echo -e "${GREEN}PASS${NC}: $name (used $LAST_TURNS turns, max $expected_max)"
        ((PASS++)) || true
        return 0
    else
        echo -e "${YELLOW}WARN${NC}: $name (used $LAST_TURNS turns, expected max $expected_max)"
        # Don't fail, just warn - turn exhaustion is informational
        return 0
    fi
}

# ============================================================================
# HOOK-BASED VERIFICATION (Ground Truth)
# ============================================================================

HOOK_LOG="/tmp/tandem-test-bash-commands.txt"

# Setup hook logging for ground-truth command verification
# Call this in setup_workspace if you need hook verification
# Automatically configures settings.json if not already set up
setup_hook_logging() {
    # Clear previous log
    rm -f "$HOOK_LOG"

    # Auto-configure hook if not present
    local settings_file="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"

    if [[ ! -f "$settings_file" ]]; then
        # Create new settings with hook
        cat > "$settings_file" << 'SETTINGS'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> /tmp/tandem-test-bash-commands.txt 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
SETTINGS
        echo "Created hook config: $settings_file"
    elif ! grep -q "tandem-test-bash-commands" "$settings_file" 2>/dev/null; then
        echo "WARN: Hook not in settings.json - manual setup required for ground-truth verification"
        echo "  Add to ~/.claude/settings.json:"
        echo '  {"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"jq -r '.tool_input.command' >> /tmp/tandem-test-bash-commands.txt"}]}]}}'
    fi

    echo "Hook logging enabled: $HOOK_LOG"
}

# Check if a specific command was executed (via hook log)
# Usage: assert_command_executed "test name" "expected_command_pattern"
assert_command_executed() {
    local name="$1"
    local pattern="$2"

    if [[ ! -f "$HOOK_LOG" ]]; then
        echo -e "${YELLOW}SKIP${NC}: $name (hook logging not enabled)"
        return 0
    fi

    if grep -qE "$pattern" "$HOOK_LOG" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}: $name (command executed)"
        ((PASS++)) || true
        return 0
    else
        echo -e "${RED}FAIL${NC}: $name (pattern '$pattern' not in hook log)"
        echo "  Hook log contents:"
        cat "$HOOK_LOG" 2>/dev/null | head -5 | sed 's/^/    /'
        ((FAIL++)) || true
        return 1
    fi
}

# Get count of commands matching pattern (via hook log)
get_command_count() {
    local pattern="$1"
    grep -cE "$pattern" "$HOOK_LOG" 2>/dev/null || echo 0
}

# ============================================================================
# UTILITIES
# ============================================================================

# Get the latest plan file from workspace or ~/.claude/plans/
get_plan_file() {
    local plan_file=""

    # Check workspace first
    for f in "$TEST_CWD"/*.md; do
        if [[ -f "$f" && $(basename "$f") != "CLAUDE.md" && $(basename "$f") != "plan-log.md" ]]; then
            if grep -qE '^\[.\] Phase' "$f" 2>/dev/null; then
                plan_file="$f"
            fi
        fi
    done

    # Check ~/.claude/plans/ if not found
    if [[ -z "$plan_file" ]]; then
        plan_file=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
    fi

    echo "$plan_file"
}

# Extract Contract entries from plan-log.md
get_contracts() {
    grep '| Contract:' "$TEST_CWD/plan-log.md" 2>/dev/null || true
}

# Extract Completion entries from plan-log.md
get_completions() {
    grep '| Completion:' "$TEST_CWD/plan-log.md" 2>/dev/null || true
}

# Extract Interaction entries from plan-log.md
get_interactions() {
    grep '| Interaction:' "$TEST_CWD/plan-log.md" 2>/dev/null || true
}

# Extract Lesson entries from plan-log.md
get_lessons() {
    grep '| Lesson:' "$TEST_CWD/plan-log.md" 2>/dev/null || true
}

# ============================================================================
# REPORTING
# ============================================================================

print_header() {
    TEST_NAME="$1"
    echo ""
    echo "============================================"
    echo "=== $TEST_NAME ==="
    echo "============================================"
    echo ""
}

print_summary() {
    echo ""
    echo "============================================"
    echo "Results: $PASS passed, $FAIL failed"
    echo "============================================"
}

# Generate JSON compliance report
generate_report() {
    local total=$((PASS + FAIL))
    local score=$((PASS * 100 / (total > 0 ? total : 1)))

    cat << EOF
{
  "test": "$TEST_NAME",
  "timestamp": "$(date -Iseconds)",
  "session_id": "$SESSION_ID",
  "workspace": "$TEST_CWD",
  "results": {
    "passed": $PASS,
    "failed": $FAIL,
    "total": $total,
    "score": $score
  },
  "metrics": {
    "total_cost_usd": $TOTAL_COST,
    "last_turns": $LAST_TURNS
  }
}
EOF
}

# ============================================================================
# STATISTICAL TESTING (n=3 quick screening per behavioral testing guide)
# ============================================================================

# Run a scenario function multiple times and report success rate
# Usage: run_statistical "scenario_name" scenario_function [trials=3]
# Returns: 0 if success rate >= 66% (2/3), 1 otherwise
run_statistical() {
    local name="$1"
    local scenario_fn="$2"
    local trials="${3:-3}"
    local success=0

    echo ""
    echo "Statistical test: $name (n=$trials)"

    for i in $(seq 1 $trials); do
        # Reset state for each trial
        PASS=0
        FAIL=0
        setup_workspace

        if $scenario_fn; then
            ((success++))
            echo "  Trial $i: PASS"
        else
            echo "  Trial $i: FAIL"
        fi

        cleanup false
        sleep 2
    done

    local rate=$((success * 100 / trials))
    echo "  Result: $success/$trials ($rate%)"

    # 66% threshold for n=3 (2/3 success)
    if [[ $success -ge 2 ]]; then
        echo -e "  ${GREEN}STATISTICAL PASS${NC}"
        return 0
    else
        echo -e "  ${RED}STATISTICAL FAIL${NC}"
        return 1
    fi
}
