#!/bin/bash
# Extract and validate fixtures from real plan-log.md data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_LOG="$SCRIPT_DIR/../../plan-log.md"
FIXTURES_DIR="$SCRIPT_DIR"

extract_and_validate() {
    local pattern="$1" output="$2" min_count="$3"

    grep "$pattern" "$PLAN_LOG" > "$FIXTURES_DIR/$output"
    local count
    count=$(wc -l < "$FIXTURES_DIR/$output")

    if [[ $count -lt $min_count ]]; then
        echo "ERR: $output has $count entries (minimum $min_count required)"
        echo "     Check if pattern '$pattern' matches plan-log.md"
        return 1
    fi
    echo "OK: $output has $count entries"
    return 0
}

echo "Extracting fixtures from $PLAN_LOG..."

# Extract with minimum counts to catch pattern mismatches
extract_and_validate '| Contract:' valid-contract.txt 5 || exit 1
extract_and_validate '| Completion:' valid-completion.txt 5 || exit 1
extract_and_validate '| Interaction:' valid-interaction.txt 10 || exit 1

# Lessons may not exist yet - optional
if grep -q '| Lesson:' "$PLAN_LOG"; then
    extract_and_validate '| Lesson:' valid-lesson.txt 1
else
    echo "SKIP: No Lesson entries found (optional)"
    touch "$FIXTURES_DIR/valid-lesson.txt"
fi

echo ""
echo "Extraction complete."
