#!/bin/bash
# Tandem Protocol Behavioral Test Harness
# Tests protocol compliance via hook-based verification
#
# Usage: ./test-harness.sh <experiment> <variant> [trials]
# Example: ./test-harness.sh 0 baseline 10

set -euo pipefail

# Configuration
EXPERIMENTS_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_BASE="/tmp/tandem-test"
TRIALS="${3:-10}"
MODEL="sonnet"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# No hook verification needed - we check output patterns for skill invocation
check_hook() {
    log_info "Using output pattern matching for plan-log skill invocation"
}

# Run a single trial
run_trial() {
    local exp="$1"
    local variant="$2"
    local trial_num="$3"
    local trial_dir="$TEST_BASE/exp${exp}/${variant}/trial${trial_num}"

    # Create isolated trial directory
    rm -rf "$trial_dir"
    mkdir -p "$trial_dir"
    cd "$trial_dir"

    # Create contract file for the test
    cat > "$trial_dir/phase-1-contract.md" << 'CONTRACT'
# Phase 1 Contract

**Created:** 2025-01-17

## Objective
Implement feature X

## Success Criteria
- [x] Criterion 1 - COMPLETE
- [x] Criterion 2 - COMPLETE

## Step 4 Checklist
- [x] 4a: Results presented to user
- [x] 4b: Approval received
CONTRACT

    # Build test input: protocol variant + scenario
    local variant_file="$EXPERIMENTS_DIR/variant-exp${exp}-${variant}.md"
    local scenario_file="$EXPERIMENTS_DIR/scenario-step5c.md"

    if [[ ! -f "$variant_file" ]]; then
        log_error "Variant file not found: $variant_file"
        return 1
    fi

    if [[ ! -f "$scenario_file" ]]; then
        log_error "Scenario file not found: $scenario_file"
        return 1
    fi

    # Run test with timeout (60s max, 8 turns)
    local output_file="$trial_dir/output.txt"
    timeout 60 bash -c 'cat "$1" "$2"' -- "$variant_file" "$scenario_file" | \
        claude -p --model "$MODEL" --max-turns 8 > "$output_file" 2>&1 || true

    # Wait for output to complete
    sleep 2

    # Evaluate results
    local skill_invoked=0
    local mentioned=0
    local file_deleted=0

    # Check if contract file was deleted (proof of execution)
    if [[ ! -f "$trial_dir/phase-1-contract.md" ]]; then
        file_deleted=1
    fi

    # Check for plan-log mention in output
    if grep -qiE 'plan-log' "$output_file"; then
        mentioned=1
    fi

    # SUCCESS = file deleted AND plan-log mentioned (executed the workflow)
    if [[ $file_deleted -eq 1 ]] && [[ $mentioned -eq 1 ]]; then
        skill_invoked=1
    fi

    # Determine result
    local result
    if [[ $skill_invoked -eq 1 ]]; then
        result="SUCCESS"
    elif [[ $mentioned -eq 1 ]]; then
        result="PARTIAL"  # Talked about it but didn't clearly invoke
    else
        result="FAILURE"
    fi

    # Save trial metadata
    cat > "$trial_dir/result.json" << EOF
{
    "experiment": "$exp",
    "variant": "$variant",
    "trial": $trial_num,
    "skill_invoked": $skill_invoked,
    "mentioned": $mentioned,
    "result": "$result"
}
EOF

    echo "$result"
}

# Run all trials for an experiment/variant
run_experiment() {
    local exp="$1"
    local variant="$2"
    local trials="$3"

    log_info "Running Experiment $exp, Variant: $variant, Trials: $trials"

    local success=0
    local partial=0
    local failure=0

    for i in $(seq 1 "$trials"); do
        printf "  Trial %2d/%d: " "$i" "$trials"
        result=$(run_trial "$exp" "$variant" "$i")

        case "$result" in
            SUCCESS)
                echo -e "${GREEN}SUCCESS${NC}"
                ((success++)) || true
                ;;
            PARTIAL)
                echo -e "${YELLOW}PARTIAL${NC}"
                ((partial++)) || true
                ;;
            FAILURE)
                echo -e "${RED}FAILURE${NC}"
                ((failure++)) || true
                ;;
        esac
    done

    # Summary
    echo ""
    log_info "Results for Exp $exp, Variant $variant:"
    echo "  SUCCESS: $success/$trials ($(( success * 100 / trials ))%)"
    echo "  PARTIAL: $partial/$trials ($(( partial * 100 / trials ))%)"
    echo "  FAILURE: $failure/$trials ($(( failure * 100 / trials ))%)"

    # Save summary
    local summary_file="$TEST_BASE/exp${exp}/${variant}/summary.json"
    cat > "$summary_file" << EOF
{
    "experiment": "$exp",
    "variant": "$variant",
    "trials": $trials,
    "success": $success,
    "partial": $partial,
    "failure": $failure,
    "success_rate": $(( success * 100 / trials ))
}
EOF

    log_info "Summary saved to $summary_file"
}

# Main
main() {
    local exp="${1:-}"
    local variant="${2:-}"

    if [[ -z "$exp" ]] || [[ -z "$variant" ]]; then
        echo "Usage: $0 <experiment> <variant> [trials]"
        echo ""
        echo "Experiments:"
        echo "  0  - Baseline (current protocol)"
        echo "  1  - Code block vs prose format"
        echo "  2  - Optional vs imperative framing"
        echo "  3  - Environment inventory"
        echo "  4  - Quote requirement"
        echo "  5  - Condition markers"
        echo "  6  - Negative control"
        echo ""
        echo "Example: $0 0 baseline 10"
        exit 1
    fi

    check_hook
    run_experiment "$exp" "$variant" "$TRIALS"
}

main "$@"
