#!/bin/bash
# UC5 Integration Test: Line References
# Verifies line numbers are updated after edits
#
# Scenario: Edit file, verify line references updated
# 1. Create file with known content
# 2. Plan references specific line
# 3. Edit inserts content (shifts lines)
# 4. Verify line references updated in results

source "$(dirname "$0")/common.sh"

print_header "UC5: Line References"

# Setup
setup_workspace
trap 'cleanup true' EXIT

# Create a file with known content at specific lines
cat > "$TEST_CWD/target.md" << 'EOF'
# Target File

Line 3: Some content here.
Line 4: More content.
Line 5: Even more.

## Important Section

Line 9: This is the target line we will reference.
Line 10: Another line.
Line 11: Final line.
EOF

git add target.md
git commit -q -m "add target file"

echo "Created target.md with known line numbers"
echo "Line 9 contains: 'This is the target line we will reference.'"
echo ""

# Start session asking to reference and modify the file
echo "Step 1: Plan task referencing target.md:9..."
RESULT=$(start_session "/tandem plan to add a header section to target.md before line 5, then update the reference to line 9" 10)
SESSION_ID=$(extract_session_id "$RESULT")

if [[ -z "$SESSION_ID" ]]; then
    echo "ERROR: Failed to start session"
    exit 1
fi
echo "Session: $SESSION_ID"

# Approve plan
echo ""
echo "Step 2: Gate 1 - proceed..."
sleep 2
resume_session "proceed" 15 > /dev/null

# Check if edit happened
echo ""
echo "Step 3: Checking edits..."

if [[ -f "$TEST_CWD/target.md" ]]; then
    echo "Current target.md:"
    head -15 "$TEST_CWD/target.md"
    echo ""

    # Check if content was inserted
    NEW_LINE_COUNT=$(wc -l < "$TEST_CWD/target.md")
    if [[ $NEW_LINE_COUNT -gt 11 ]]; then
        echo -e "${GREEN}PASS${NC}: File was edited (now $NEW_LINE_COUNT lines)"
        ((PASS++)) || true

        # The original "target line" should have shifted
        # Find what line it's on now
        NEW_TARGET_LINE=$(grep -n "This is the target line" "$TEST_CWD/target.md" | cut -d: -f1)
        if [[ -n "$NEW_TARGET_LINE" && "$NEW_TARGET_LINE" != "9" ]]; then
            echo -e "${GREEN}PASS${NC}: Target line shifted from 9 to $NEW_TARGET_LINE"
            ((PASS++)) || true
        else
            echo -e "${YELLOW}WARN${NC}: Target line position unchanged or not found"
        fi
    else
        echo -e "${YELLOW}WARN${NC}: File may not have been edited ($NEW_LINE_COUNT lines)"
    fi
else
    echo -e "${RED}FAIL${NC}: target.md not found"
    ((FAIL++)) || true
fi

# Request results presentation
echo ""
echo "Step 4: Request grade to see results presentation..."
sleep 2
GRADE_RESULT=$(resume_session "grade" 5)

# Check for line reference awareness
echo ""
echo "UC5 Line Reference Checks..."

# Check if response mentions line numbers
if echo "$GRADE_RESULT" | grep -qE 'line [0-9]+|:[0-9]+'; then
    echo -e "${GREEN}PASS${NC}: Response contains line references"
    ((PASS++)) || true
else
    echo -e "${YELLOW}WARN${NC}: No explicit line references in response"
fi

# Check for awareness of line shift
if echo "$GRADE_RESULT" | grep -qiE 'shift|moved|updated|changed.*line'; then
    echo -e "${GREEN}PASS${NC}: Mentions line shift awareness"
    ((PASS++)) || true
else
    echo -e "${YELLOW}INFO${NC}: No explicit mention of line shift"
fi

# Check plan-log for line references in entries
if grep -qE ':[0-9]+\)' "$TEST_CWD/plan-log.md" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}: plan-log.md has line references in evidence"
    ((PASS++)) || true
else
    echo -e "${YELLOW}INFO${NC}: No line references in plan-log.md evidence"
fi

# Print summary
print_summary

# Generate report
echo ""
generate_report

exit $FAIL
