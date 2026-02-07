#!/bin/bash
# Behavioral Integration Test - Protocol Walk
# Analyzes a transcript to verify protocol compliance at each checkpoint

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Test against provided transcript and log, or use defaults
TRANSCRIPT="${1:-}"
LOG_FILE="${2:-plan-log.md}"

echo "=== Protocol Walk Integration Test ==="
echo ""

if [[ -z "$TRANSCRIPT" ]]; then
    echo "Usage: $0 <transcript.jsonl> [plan-log.md]"
    echo ""
    echo "This test analyzes a Claude Code session transcript to verify"
    echo "protocol compliance. Run a tandem session first, then test:"
    echo ""
    echo "  1. Start session: claude"
    echo "  2. Run: /tandem implement fizzbuzz"
    echo "  3. Walk through: proceed -> grade -> improve -> proceed"
    echo "  4. Find transcript in ~/.claude/projects/<project>/"
    echo "  5. Run: $0 <transcript.jsonl> plan-log.md"
    echo ""
    echo "Compliance checks:"
    echo "  - TaskAPI: create, in_progress, completed, deleted"
    echo "  - Telescoping: tasks expand/collapse at phase boundaries"
    echo "  - Logging: Contract (Gate 1), Completion (Gate 2), Interaction (grade/improve)"
    echo "  - Criteria: Completion items match Contract items with evidence"
    exit 0
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
    echo "Error: Transcript not found: $TRANSCRIPT"
    exit 1
fi

PASS=0
FAIL=0

# === TaskAPI Compliance ===
echo "=== TaskAPI Compliance ==="

# T1: TaskCreate calls present
if grep -q '"name":"TaskCreate"' "$TRANSCRIPT"; then
    echo "PASS: T1 - TaskCreate calls found"
    ((PASS++))
else
    echo "FAIL: T1 - No TaskCreate calls"
    ((FAIL++))
fi

# T2: TaskUpdate with in_progress
if grep -q '"name":"TaskUpdate"' "$TRANSCRIPT" && grep -q 'in_progress' "$TRANSCRIPT"; then
    echo "PASS: T2 - TaskUpdate in_progress found"
    ((PASS++))
else
    echo "FAIL: T2 - No TaskUpdate in_progress"
    ((FAIL++))
fi

# T3: TaskUpdate with completed
if grep -q '"name":"TaskUpdate"' "$TRANSCRIPT" && grep -q 'completed' "$TRANSCRIPT"; then
    echo "PASS: T3 - TaskUpdate completed found"
    ((PASS++))
else
    echo "FAIL: T3 - No TaskUpdate completed"
    ((FAIL++))
fi

# T4: TaskUpdate with deleted (telescoping cleanup)
if grep -q '"name":"TaskUpdate"' "$TRANSCRIPT" && grep -q 'deleted' "$TRANSCRIPT"; then
    echo "PASS: T4 - TaskUpdate deleted found (telescoping)"
    ((PASS++))
else
    echo "FAIL: T4 - No TaskUpdate deleted (telescoping)"
    ((FAIL++))
fi

echo ""

# === Logging Compliance ===
echo "=== Logging Compliance ==="

if [[ ! -f "$LOG_FILE" ]]; then
    echo "SKIP: Log file not found: $LOG_FILE"
    echo "      (Create plan-log.md or specify path as second argument)"
else
    # L1: Contract entry at Gate 1
    if grep -qE 'Contract:' "$LOG_FILE"; then
        echo "PASS: L1 - Contract entry found"
        ((PASS++))
    else
        echo "FAIL: L1 - No Contract entry"
        ((FAIL++))
    fi

    # L2: Contract has criteria checkboxes
    if grep -qE 'Contract:.*\[ \]' "$LOG_FILE"; then
        echo "PASS: L2 - Contract has criteria checkboxes"
        ((PASS++))
    else
        echo "FAIL: L2 - Contract missing criteria checkboxes"
        ((FAIL++))
    fi

    # L3: Completion entry at Gate 2
    if grep -qE 'Completion:' "$LOG_FILE"; then
        echo "PASS: L3 - Completion entry found"
        ((PASS++))
    else
        echo "FAIL: L3 - No Completion entry"
        ((FAIL++))
    fi

    # L4: Completion has evidence
    if grep -qE 'Completion:.*\[x\].*\(' "$LOG_FILE"; then
        echo "PASS: L4 - Completion has evidence"
        ((PASS++))
    else
        echo "FAIL: L4 - Completion missing evidence"
        ((FAIL++))
    fi

    # L5: Interaction entry for grade
    if grep -qE 'Interaction:.*grade' "$LOG_FILE"; then
        echo "PASS: L5 - Interaction (grade) entry found"
        ((PASS++))
    else
        echo "FAIL: L5 - No Interaction (grade) entry"
        ((FAIL++))
    fi

    # L6: Interaction entry for improve
    if grep -qE 'Interaction:.*improve' "$LOG_FILE"; then
        echo "PASS: L6 - Interaction (improve) entry found"
        ((PASS++))
    else
        echo "FAIL: L6 - No Interaction (improve) entry"
        ((FAIL++))
    fi
fi

echo ""

# === Criteria Matching ===
echo "=== Criteria Matching ==="

if [[ -f "$LOG_FILE" ]]; then
    # Run criteria matcher
    if bash "$SCRIPT_DIR/lib/criteria-matcher.sh" "$LOG_FILE" > /tmp/criteria-match.out 2>&1; then
        echo "PASS: C1 - All Contract criteria matched in Completion"
        ((PASS++))
        cat /tmp/criteria-match.out | head -10
    else
        echo "FAIL: C1 - Criteria mismatch"
        ((FAIL++))
        cat /tmp/criteria-match.out | head -10
    fi
else
    echo "SKIP: No log file for criteria matching"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
