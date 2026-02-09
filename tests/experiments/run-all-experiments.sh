#!/bin/bash
# TaskAPI Compliance Experiments Runner
# Tests 5 mechanisms to achieve TaskAPI compliance without CLAUDE.md system-reminder
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RESULTS_FILE="/tmp/taskapi-results.md"
SETTINGS_BACKUP="$HOME/.claude/settings.json.exp-backup"
PRETOOLUSE_LOGGER='{"hooks":{"PreToolUse":[{"matcher":"Task.*","hooks":[{"type":"command","command":"bash -c '\''read INPUT; echo \"$(date -Iseconds) $(echo $INPUT | jq -r .tool_name)\" >> /tmp/taskapi-current/tool-calls.log'\''"}]}]}}'

echo "=== TaskAPI Compliance Experiments ==="
echo "Project root: $PROJECT_ROOT"
echo ""

# Backup settings
if [[ -f ~/.claude/settings.json ]]; then
    cp ~/.claude/settings.json "$SETTINGS_BACKUP"
    echo "Settings backed up to $SETTINGS_BACKUP"
else
    echo "{}" > "$SETTINGS_BACKUP"
    echo "No existing settings, created empty backup"
fi

cleanup() {
    echo ""
    echo "=== Cleanup ==="
    cp "$SETTINGS_BACKUP" ~/.claude/settings.json
    rm -rf /tmp/taskapi-exp* /tmp/taskapi-current /tmp/settings-template.json
    rm -f "$PROJECT_ROOT/tests/hooks/enforce-taskcreate.sh"
    echo "Settings restored, temp files cleaned"
}
trap cleanup EXIT

echo "| Exp | Mechanism | TaskCreate Calls | Result |" > "$RESULTS_FILE"
echo "|-----|-----------|------------------|--------|" >> "$RESULTS_FILE"

run_exp() {
    local num="$1" name="$2" count="$3"
    local result="FAIL"
    [[ "$count" -gt 0 ]] && result="PASS"
    echo "| $num | $name | $count | $result |" >> "$RESULTS_FILE"
    echo "$(date -Iseconds) | Interaction: Exp $num [$name] -> $count TaskCreate calls [$result]" >> "$PROJECT_ROOT/plan-log.md"
    echo "  Result: $count TaskCreate calls [$result]"
}

setup_exp() {
    local num="$1"
    echo ""
    echo "=== Experiment $num ==="
    mkdir -p "/tmp/taskapi-exp$num"
    rm -f /tmp/taskapi-current
    ln -sf "/tmp/taskapi-exp$num" /tmp/taskapi-current
    touch "/tmp/taskapi-current/tool-calls.log"
}

# === Exp 3: Explicit Prompt (simplest) ===
setup_exp 3
echo "Testing: Explicit prompt instruction"
echo "$PRETOOLUSE_LOGGER" > ~/.claude/settings.json
cd "$PROJECT_ROOT"
claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz" 2>&1 | tee /tmp/taskapi-exp3/plan.log
claude --dangerously-skip-permissions -p "proceed. IMPORTANT: You must now invoke the TaskCreate tool for each task in the plan." --continue 2>&1 | tee /tmp/taskapi-exp3/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp3/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "3" "Explicit Prompt" "$COUNT"

# === Exp 4a: Single-turn combined ===
setup_exp 4a
echo "Testing: Single-turn combined (plan + proceed)"
echo "$PRETOOLUSE_LOGGER" > ~/.claude/settings.json
claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz, then proceed immediately" 2>&1 | tee /tmp/taskapi-exp4a/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp4a/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "4a" "Single-turn" "$COUNT"

# === Exp 4b: Fresh session ===
setup_exp 4b
echo "Testing: Fresh session (no --continue)"
echo "$PRETOOLUSE_LOGGER" > ~/.claude/settings.json
claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz" 2>&1 | tee /tmp/taskapi-exp4b/plan.log
claude --dangerously-skip-permissions -p "continue where you left off and proceed with Gate 1" 2>&1 | tee /tmp/taskapi-exp4b/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp4b/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "4b" "Fresh Session" "$COUNT"

# === Exp 2: SessionStart context injection ===
setup_exp 2
echo "Testing: SessionStart context injection"
cat > ~/.claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "PreToolUse": [{"matcher": "Task.*", "hooks": [{"type": "command", "command": "bash -c 'read INPUT; echo \"$(date -Iseconds) $(echo $INPUT | jq -r .tool_name)\" >> /tmp/taskapi-current/tool-calls.log'"}]}],
    "SessionStart": [{"matcher": "", "hooks": [{"type": "command", "command": "echo '{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"MANDATORY: When user says proceed at Gate 1, invoke TaskCreate tool for each task.\"}}'"}]}]
  }
}
SETTINGS
claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz" 2>&1 | tee /tmp/taskapi-exp2/plan.log
claude --dangerously-skip-permissions -p "proceed" --continue 2>&1 | tee /tmp/taskapi-exp2/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp2/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "2" "SessionStart" "$COUNT"

# === Exp 1: Stop hook enforcement ===
setup_exp 1
echo "Testing: Stop hook enforcement"
mkdir -p "$PROJECT_ROOT/tests/hooks"
cat > "$PROJECT_ROOT/tests/hooks/enforce-taskcreate.sh" << 'SCRIPT'
#!/bin/bash
INPUT=$(cat)
TOOL_LOG="${TOOL_LOG:-/tmp/taskapi-current/tool-calls.log}"
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
[[ "$STOP_HOOK_ACTIVE" == "true" ]] && exit 0
if grep -q 'TaskCreate' "$TOOL_LOG" 2>/dev/null; then
    exit 0
else
    echo '{"decision": "block", "reason": "Protocol requires TaskCreate invocation. Please call TaskCreate now."}'
fi
SCRIPT
chmod +x "$PROJECT_ROOT/tests/hooks/enforce-taskcreate.sh"

# Use unquoted heredoc for variable expansion
cat > ~/.claude/settings.json << SETTINGS
{
  "hooks": {
    "PreToolUse": [{"matcher": "Task.*", "hooks": [{"type": "command", "command": "bash -c 'read INPUT; echo \"\$(date -Iseconds) \$(echo \$INPUT | jq -r .tool_name)\" >> /tmp/taskapi-current/tool-calls.log'"}]}],
    "Stop": [{"matcher": "", "hooks": [{"type": "command", "command": "TOOL_LOG=/tmp/taskapi-current/tool-calls.log bash $PROJECT_ROOT/tests/hooks/enforce-taskcreate.sh"}]}]
  }
}
SETTINGS

claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz" 2>&1 | tee /tmp/taskapi-exp1/plan.log
claude --dangerously-skip-permissions -p "proceed" --continue 2>&1 | tee /tmp/taskapi-exp1/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp1/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "1" "Stop Hook" "$COUNT"

# === Exp 5: Agent-based hook ===
setup_exp 5
echo "Testing: Agent-based Stop hook (can read transcript)"
cat > ~/.claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "PreToolUse": [{"matcher": "Task.*", "hooks": [{"type": "command", "command": "bash -c 'read INPUT; echo \"$(date -Iseconds) $(echo $INPUT | jq -r .tool_name)\" >> /tmp/taskapi-current/tool-calls.log'"}]}],
    "Stop": [{"matcher": "", "hooks": [{"type": "agent", "prompt": "Check if TaskCreate was invoked. Read the transcript file at transcript_path from $ARGUMENTS. Search for TaskCreate. Respond {\"ok\": true} if found, {\"ok\": false, \"reason\": \"Invoke TaskCreate now.\"} if not.", "timeout": 60}]}]
  }
}
SETTINGS
claude --dangerously-skip-permissions -p "/tandem plan fizzbuzz" 2>&1 | tee /tmp/taskapi-exp5/plan.log
claude --dangerously-skip-permissions -p "proceed" --continue 2>&1 | tee /tmp/taskapi-exp5/output.log
COUNT=$(grep -c 'TaskCreate' /tmp/taskapi-exp5/tool-calls.log 2>/dev/null | tr -d '[:space:]' || echo 0)
run_exp "5" "Agent Hook" "$COUNT"

echo ""
echo "=========================================="
echo "=== FINAL RESULTS ==="
echo "=========================================="
cat "$RESULTS_FILE"
echo ""
echo "Detailed logs in /tmp/taskapi-exp*/"
