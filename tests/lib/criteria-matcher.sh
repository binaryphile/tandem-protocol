#!/bin/bash
# Cross-reference Contract/Completion criteria in plan-log.md

# Usage: criteria-matcher.sh <plan-log.md>
# Verifies: Each Contract criterion appears in Completion with evidence
# Returns: PASS/FAIL for each criterion

LOG_FILE="$1"

if [[ -z "$LOG_FILE" ]]; then
    echo "Usage: $0 <plan-log.md>" >&2
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file not found: $LOG_FILE" >&2
    exit 1
fi

# Get most recent Contract entry
CONTRACT=$(grep -E "Contract:" "$LOG_FILE" | tail -1)
if [[ -z "$CONTRACT" ]]; then
    echo "FAIL: No Contract entry found"
    exit 1
fi

# Get most recent Completion entry
COMPLETION=$(grep -E "Completion:" "$LOG_FILE" | tail -1)
if [[ -z "$COMPLETION" ]]; then
    echo "FAIL: No Completion entry found"
    exit 1
fi

# Extract criteria from Contract ([ ] criterion patterns)
CONTRACT_CRITERIA=$(echo "$CONTRACT" | grep -oE '\[ \] [^,\|]+' | sed 's/\[ \] //')

# Check each criterion appears in Completion with [x] and evidence
PASS=0
FAIL=0

while IFS= read -r criterion; do
    [[ -z "$criterion" ]] && continue
    # Look for [x] criterion (evidence) pattern
    if echo "$COMPLETION" | grep -qE "\[x\] $criterion.*\("; then
        echo "PASS: $criterion - found with evidence"
        ((PASS++))
    elif echo "$COMPLETION" | grep -qE "\[x\] $criterion"; then
        echo "WARN: $criterion - found but missing evidence"
        ((PASS++))
    else
        echo "FAIL: $criterion - not found in Completion"
        ((FAIL++))
    fi
done <<< "$CONTRACT_CRITERIA"

echo ""
echo "Criteria matched: $PASS"
echo "Criteria missing: $FAIL"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
