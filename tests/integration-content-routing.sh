#!/bin/bash
# Focused Integration Test - UC2 Content Routing (HOW vs WHAT)
# Verifies plan file contains methodology, Contract contains scope
#
# UC2 Guard Conditions:
#   - Plan file contains "Success Criteria" → FAIL (Contract content in plan)
#   - Plan file contains "Deliverables" list → FAIL (Contract content in plan)
#   - Contract entry contains "Methodology" → FAIL (Plan content in Contract)
#   - Contract entry contains "Research strategy" → FAIL (Plan content in Contract)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0

check() {
    local name="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $name"
        ((PASS++)) || true
    else
        echo "FAIL: $name (expected $expected, got $actual)"
        ((FAIL++)) || true
    fi
}

echo "=== UC2 Content Routing Test ==="
echo ""

# Find plan files
PLAN_FILES=$(find ~/.claude/plans -name "*.md" 2>/dev/null | head -5)
PLAN_LOG="$PROJECT_DIR/plan-log.md"

if [[ -z "$PLAN_FILES" ]] && [[ ! -f "$PLAN_LOG" ]]; then
    echo "SKIP: No plan files or plan-log.md found"
    exit 0
fi

echo "Checking plan files for Contract content (should NOT be present)..."
for plan_file in $PLAN_FILES; do
    [[ ! -f "$plan_file" ]] && continue

    # Plan file should NOT contain Contract-style content
    if grep -qi "Success Criteria" "$plan_file" 2>/dev/null; then
        echo "FAIL: Plan file contains 'Success Criteria' (Contract content): $plan_file"
        ((FAIL++)) || true
    else
        echo "PASS: No 'Success Criteria' in plan file: $(basename "$plan_file")"
        ((PASS++)) || true
    fi

    # Check for "Deliverables" as a section header (not just the word)
    if grep -qE "^#+.*Deliverables|^Deliverables:" "$plan_file" 2>/dev/null; then
        echo "FAIL: Plan file contains 'Deliverables' section (Contract content): $plan_file"
        ((FAIL++)) || true
    else
        echo "PASS: No 'Deliverables' section in plan file: $(basename "$plan_file")"
        ((PASS++)) || true
    fi
done

echo ""
echo "Checking Contract entries for Plan content (should NOT be present)..."

if [[ -f "$PLAN_LOG" ]]; then
    # Extract Contract entries
    CONTRACT_ENTRIES=$(grep '| Contract:' "$PLAN_LOG" 2>/dev/null)

    if [[ -n "$CONTRACT_ENTRIES" ]]; then
        # Contract should NOT contain methodology language
        if echo "$CONTRACT_ENTRIES" | grep -qi "methodology"; then
            echo "FAIL: Contract contains 'methodology' (Plan content)"
            ((FAIL++)) || true
        else
            echo "PASS: No 'methodology' in Contract entries"
            ((PASS++)) || true
        fi

        if echo "$CONTRACT_ENTRIES" | grep -qi "research strategy"; then
            echo "FAIL: Contract contains 'research strategy' (Plan content)"
            ((FAIL++)) || true
        else
            echo "PASS: No 'research strategy' in Contract entries"
            ((PASS++)) || true
        fi

        if echo "$CONTRACT_ENTRIES" | grep -qi "approach"; then
            echo "WARN: Contract contains 'approach' - verify it's scope not methodology"
        fi
    else
        echo "INFO: No Contract entries found in plan-log.md"
    fi
else
    echo "INFO: plan-log.md not found"
fi

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

exit $FAIL
