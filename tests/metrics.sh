#!/bin/bash
# Tandem Protocol Metrics
# Measures protocol health across compliance, quality, and efficiency dimensions

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
README="$PROJECT_ROOT/README.md"
PLAN_LOG="$PROJECT_ROOT/plan-log.md"
GUIDES_DIR="$PROJECT_ROOT/docs/guides"

echo "=== Tandem Protocol Metrics ==="
echo "Project: $PROJECT_ROOT"
echo "Date: $(date -Iseconds)"
echo ""

# --- Tier 1: Core Compliance ---
echo "## Tier 1: Core Compliance"
echo ""

# Gate logging
CONTRACTS=$(grep -c "| Contract:" "$PLAN_LOG" 2>/dev/null) || CONTRACTS=0
COMPLETIONS_ALL=$(grep -c "| Completion:" "$PLAN_LOG" 2>/dev/null) || COMPLETIONS_ALL=0
COMPLETIONS_PHASE=$(grep -ciE '\| Completion:.*[Pp]hase' "$PLAN_LOG" 2>/dev/null) || COMPLETIONS_PHASE=0
echo "Gate Logging:"
echo "  Contracts (G1):     $CONTRACTS"
echo "  Phase completions:  $COMPLETIONS_PHASE"
echo "  All completions:    $COMPLETIONS_ALL"
if [ "$CONTRACTS" -gt 0 ]; then
    GATE_RATIO=$((COMPLETIONS_PHASE * 100 / CONTRACTS))
    echo "  Phase close rate:   ${GATE_RATIO}% (Phase Completions/Contracts)"
else
    GATE_RATIO=0
fi
echo ""

# Interaction logging
INTERACTIONS=$(grep -c "| Interaction:" "$PLAN_LOG" 2>/dev/null || echo 0)
GRADES=$(grep -c "Interaction:.*grade" "$PLAN_LOG" 2>/dev/null || echo 0)
IMPROVES=$(grep -c "Interaction:.*improve" "$PLAN_LOG" 2>/dev/null || echo 0)
echo "Interaction Logging:"
echo "  Total interactions: $INTERACTIONS"
echo "  Grade cycles:       $GRADES"
echo "  Improve cycles:     $IMPROVES"
echo ""

# Decision capture (in plan-log or guides)
DECISIONS_LOG=$(grep -ciE "decision|design.*choice|chose|selected" "$PLAN_LOG" 2>/dev/null) || DECISIONS_LOG=0
if [ -d "$GUIDES_DIR" ]; then
    DECISIONS_GUIDES=$(grep -rciE "decision|design.*choice" "$GUIDES_DIR" 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
else
    DECISIONS_GUIDES=0
fi
echo "Decision Capture:"
echo "  In plan-log.md:     $DECISIONS_LOG"
echo "  In guides:          $DECISIONS_GUIDES"
echo ""

# --- Tier 2: Quality Signals ---
echo "## Tier 2: Quality Signals"
echo ""

# Lesson capture
LESSONS_LOG=$(grep -c "| Lesson:" "$PLAN_LOG" 2>/dev/null || echo 0)
LESSONS_GUIDES=$(grep -rc "### " "$GUIDES_DIR"/*.md 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
echo "Lesson Capture:"
echo "  In plan-log.md:     $LESSONS_LOG"
echo "  Guide sections:     $LESSONS_GUIDES (### headers in guides)"
echo ""

# G/I cycle effectiveness (count grade improvements mentioned)
GRADE_IMPROVEMENTS=$(grep -ciE "improve.*->.*[AB]|grade.*improved|fixed" "$PLAN_LOG" 2>/dev/null || echo 0)
echo "G/I Cycle Outcomes:"
echo "  Improvements noted: $GRADE_IMPROVEMENTS"
echo ""

# --- Tier 3: Efficiency ---
echo "## Tier 3: Efficiency"
echo ""

# README token count
README_CHARS=$(wc -c < "$README" 2>/dev/null || echo 0)
README_WORDS=$(wc -w < "$README" 2>/dev/null || echo 0)
README_TOKENS=$((README_CHARS / 4))
README_LINES=$(wc -l < "$README" 2>/dev/null || echo 0)
echo "README Size:"
echo "  Lines:              $README_LINES"
echo "  Words:              $README_WORDS"
echo "  Tokens (est):       $README_TOKENS"
if [ "$README_TOKENS" -gt 4000 ]; then
    echo "  Status:             ⚠️  OVER 4000 token target"
else
    echo "  Status:             ✓ Under 4000 token target"
fi
echo ""

# Plan-log size
if [ -f "$PLAN_LOG" ]; then
    LOG_LINES=$(wc -l < "$PLAN_LOG")
    LOG_ENTRIES=$((CONTRACTS + COMPLETIONS + INTERACTIONS + LESSONS_LOG))
    echo "Plan Log Size:"
    echo "  Lines:              $LOG_LINES"
    echo "  Total entries:      $LOG_ENTRIES"
fi
echo ""

# --- Summary ---
echo "=== Summary ==="
echo ""
echo "| Metric | Value | Target | Status |"
echo "|--------|-------|--------|--------|"
echo "| Phase close rate | ${GATE_RATIO}% | 100% | $([ "$GATE_RATIO" -ge 100 ] && echo '✓' || echo '⚠️') |"
echo "| Interactions logged | $INTERACTIONS | >0 | $([ "$INTERACTIONS" -gt 0 ] && echo '✓' || echo '⚠️') |"
echo "| Lessons captured | $LESSONS_LOG | >0 | $([ "$LESSONS_LOG" -gt 0 ] && echo '✓' || echo '—') |"
echo "| README tokens | $README_TOKENS | <4000 | $([ "$README_TOKENS" -lt 4000 ] && echo '✓' || echo '⚠️') |"
