#!/bin/bash
# Unit tests for Tandem Protocol validators
# Run: bash tests/unit-validators.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validators.sh"

PASS=0
FAIL=0

# Test runner
run_test() {
    local name="$1" expected="$2"
    shift 2
    local result exit_code

    # Capture both output and exit code
    result=$("$@" 2>&1)
    exit_code=$?

    if [[ $expected == "pass" && $exit_code -eq 0 ]]; then
        echo "PASS: $name"
        ((PASS++)) || true
    elif [[ $expected == "fail" && $exit_code -ne 0 ]]; then
        echo "PASS: $name (expected failure)"
        ((PASS++)) || true
    else
        echo "FAIL: $name"
        echo "      Expected: $expected, Got: exit=$exit_code"
        [[ -n "$result" ]] && echo "      Output: $result"
        ((FAIL++)) || true
    fi
}

echo "=== Timestamp Validation ==="
run_test "timestamp_valid" pass validate_timestamp "2026-02-09T12:00:00Z"
run_test "timestamp_no_T" fail validate_timestamp "2026-02-09 12:00:00Z"
run_test "timestamp_no_Z" fail validate_timestamp "2026-02-09T12:00:00"

echo ""
echo "=== Contract Entry Validation ==="
run_test "contract_valid" pass validate_contract_entry "2026-02-09T12:00:00Z | Contract: Phase 1 | [ ] auth, [ ] tests"
run_test "contract_single_criterion" pass validate_contract_entry "2026-02-09T12:00:00Z | Contract: Phase 1 | [ ] auth"
run_test "contract_no_checkbox" fail validate_contract_entry "2026-02-09T12:00:00Z | Contract: Phase 1 | auth, tests"
run_test "contract_bad_timestamp" fail validate_contract_entry "2026-02-09 12:00:00Z | Contract: Phase 1 | [ ] auth"
run_test "contract_missing_marker" fail validate_contract_entry "2026-02-09T12:00:00Z | Phase 1 | [ ] auth"

echo ""
echo "=== Completion Entry Validation ==="
run_test "completion_valid" pass validate_completion_entry "2026-02-09T12:00:00Z | Completion: Phase 1 | [x] auth (done), [x] tests (pass)"
run_test "completion_with_removed" pass validate_completion_entry "2026-02-09T12:00:00Z | Completion: Phase 1 | [x] auth (done), [-] tests (deferred)"
run_test "completion_with_added" pass validate_completion_entry "2026-02-09T12:00:00Z | Completion: Phase 1 | [x] auth (done), [+] extra (added per request)"
run_test "completion_empty_evidence" fail validate_completion_entry "2026-02-09T12:00:00Z | Completion: Phase 1 | [x] auth ()"
run_test "completion_no_evidence" fail validate_completion_entry "2026-02-09T12:00:00Z | Completion: Phase 1 | [x] auth"
run_test "completion_bad_timestamp" fail validate_completion_entry "2026-02-09 12:00:00Z | Completion: Phase 1 | [x] auth (done)"

echo ""
echo "=== Interaction Entry Validation ==="
run_test "interaction_valid" pass validate_interaction_entry "2026-02-09T12:00:00Z | Interaction: grade -> B+/85"
run_test "interaction_improve" pass validate_interaction_entry "2026-02-09T12:00:00Z | Interaction: improve -> fixed edge case"
run_test "interaction_unicode_arrow" fail validate_interaction_entry "2026-02-09T12:00:00Z | Interaction: grade → B+/85"
run_test "interaction_no_arrow" fail validate_interaction_entry "2026-02-09T12:00:00Z | Interaction: grade B+/85"
run_test "interaction_bad_timestamp" fail validate_interaction_entry "2026-02-09 12:00:00Z | Interaction: grade -> B+/85"

echo ""
echo "=== Lesson Entry Validation ==="
run_test "lesson_valid" pass validate_lesson_entry "2026-02-09T12:00:00Z | Lesson: Test patterns -> protocol-guide.md | context"
run_test "lesson_no_arrow" fail validate_lesson_entry "2026-02-09T12:00:00Z | Lesson: Test patterns protocol-guide.md | context"
run_test "lesson_bad_timestamp" fail validate_lesson_entry "2026-02-09 12:00:00Z | Lesson: Test patterns -> guide.md | context"

echo ""
echo "=== Criteria Extraction ==="
# Test extract_criteria
extracted=$(extract_criteria "2026-02-09T12:00:00Z | Contract: Phase 1 | [ ] auth, [ ] tests, [ ] docs")
if [[ $(echo "$extracted" | wc -l) -eq 3 ]]; then
    echo "PASS: extract_criteria_count"
    ((PASS++))
else
    echo "FAIL: extract_criteria_count (expected 3, got $(echo "$extracted" | wc -l))"
    ((FAIL++))
fi

if echo "$extracted" | grep -q "^auth$"; then
    echo "PASS: extract_criteria_content"
    ((PASS++))
else
    echo "FAIL: extract_criteria_content (missing 'auth')"
    ((FAIL++))
fi

echo ""
echo "=== Criteria Matching ==="
CONTRACT="2026-02-09T12:00:00Z | Contract: Phase 1 | [ ] auth, [ ] tests"
run_test "match_criteria_all_present" pass match_criteria "$CONTRACT" "2026-02-09T12:30:00Z | Completion: Phase 1 | [x] auth (done), [x] tests (pass)"
run_test "match_criteria_with_removed" pass match_criteria "$CONTRACT" "2026-02-09T12:30:00Z | Completion: Phase 1 | [x] auth (done), [-] tests (deferred)"
run_test "match_criteria_missing" fail match_criteria "$CONTRACT" "2026-02-09T12:30:00Z | Completion: Phase 1 | [x] auth (done)"
run_test "match_criteria_empty_evidence" fail match_criteria "$CONTRACT" "2026-02-09T12:30:00Z | Completion: Phase 1 | [x] auth (), [x] tests (pass)"

echo ""
echo "=== Evidence Validation ==="
run_test "evidence_valid" pass validate_evidence "auth (done)"
run_test "evidence_empty_parens" fail validate_evidence "auth ()"
run_test "evidence_whitespace_only" fail validate_evidence "auth (   )"

echo ""
echo "=== Plan Hierarchy Validation ==="
FIXTURES="$SCRIPT_DIR/fixtures"
run_test "hierarchy_valid" pass validate_plan_hierarchy "$FIXTURES/plan-valid.md"
run_test "hierarchy_collapsed_children" fail validate_plan_hierarchy "$FIXTURES/plan-invalid-collapsed.md"
run_test "hierarchy_not_expanded" fail validate_plan_hierarchy "$FIXTURES/plan-invalid-not-expanded.md"
run_test "hierarchy_future_not_skeleton" fail validate_plan_hierarchy "$FIXTURES/plan-invalid-future.md"
run_test "hierarchy_file_not_found" fail validate_plan_hierarchy "$FIXTURES/nonexistent.md"

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

exit $FAIL
