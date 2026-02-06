#!/bin/bash
# UC9 IAPI Stage Model - Behavioral Tests
# Tests that tandem-protocol.md contains IAPI stage patterns

PROTOCOL="../tandem-protocol.md"

echo "=== UC9 IAPI Stage Model Tests ==="
echo "Testing: $PROTOCOL"
echo ""

PASS=0
FAIL=0

# T1: Stage guides referenced
if grep -qE 'investigation-guide|analysis-guide|planning-guide' "$PROTOCOL"; then
    echo "PASS: T1 - Stage guides referenced"
    ((PASS++))
else
    echo "FAIL: T1 - Stage guides referenced"
    echo "      Pattern not found: investigation-guide|analysis-guide|planning-guide"
    ((FAIL++))
fi

# T2: Subagent with guide loading
if grep -qE '[Ss]ubagent.*[Ee]xplore|[Ss]ubagent.*[Pp]lan' "$PROTOCOL"; then
    echo "PASS: T2 - Subagent with guide loading"
    ((PASS++))
else
    echo "FAIL: T2 - Subagent with guide loading"
    echo "      Pattern not found: subagent.*Explore|subagent.*Plan"
    ((FAIL++))
fi

# T3: Lessons Applied/Missed in output
if grep -qE 'Lessons Applied|Lessons Missed' "$PROTOCOL"; then
    echo "PASS: T3 - Lessons Applied/Missed in output"
    ((PASS++))
else
    echo "FAIL: T3 - Lessons Applied/Missed in output"
    echo "      Pattern not found: Lessons Applied|Lessons Missed"
    ((FAIL++))
fi

# T4: Lesson routing by stage (looks for lesson list or stage-to-guide mapping)
if grep -qE 'non_actionable_lessons|"I":.*investigation-guide|"A":.*analysis-guide' "$PROTOCOL"; then
    echo "PASS: T4 - Lesson routing by stage"
    ((PASS++))
else
    echo "FAIL: T4 - Lesson routing by stage"
    echo "      Pattern not found: non_actionable_lessons|stage-to-guide mapping"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
