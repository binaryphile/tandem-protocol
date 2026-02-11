#!/bin/bash
# Pure validation functions for Tandem Protocol artifacts
# All functions return 0 on success, 1 on failure
# Error format: ERR:<CATEGORY>:<CODE>:<CONTEXT>

# Validate ISO8601 timestamp format: YYYY-MM-DDTHH:MM:SSZ
validate_timestamp() {
    local ts="$1"
    if [[ ! $ts =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
        echo "ERR:TIMESTAMP:invalid_format:$ts"
        return 1
    fi
    return 0
}

# Validate Contract entry format (supports multi-line)
# Format: TIMESTAMP | Contract: [phase]
#         [ ] criterion1
#         [ ] criterion2
validate_contract_entry() {
    local entry="$1"

    # Extract timestamp from first line
    local first_line ts
    first_line=$(echo "$entry" | head -1)
    ts=$(echo "$first_line" | cut -d'|' -f1 | tr -d ' ')
    if ! validate_timestamp "$ts" >/dev/null 2>&1; then
        echo "ERR:CONTRACT:bad_timestamp:$ts"
        return 1
    fi

    # Must have "Contract:" marker in first line
    if [[ ! $first_line =~ \|[[:space:]]*Contract: ]]; then
        echo "ERR:CONTRACT:missing_marker:$entry"
        return 1
    fi

    # Must have at least one checkbox criterion [ ] (can be on any line)
    if [[ ! $entry =~ \[\ \] ]]; then
        echo "ERR:CONTRACT:missing_checkbox:$entry"
        return 1
    fi

    return 0
}

# Validate Completion entry format (supports multi-line)
# Format: TIMESTAMP | Completion: [phase]
#         [x] criterion1 (evidence)
#         [x] criterion2 (evidence)
validate_completion_entry() {
    local entry="$1"

    # Extract timestamp from first line
    local first_line ts
    first_line=$(echo "$entry" | head -1)
    ts=$(echo "$first_line" | cut -d'|' -f1 | tr -d ' ')
    if ! validate_timestamp "$ts" >/dev/null 2>&1; then
        echo "ERR:COMPLETION:bad_timestamp:$ts"
        return 1
    fi

    # Must have "Completion:" marker in first line
    if [[ ! $first_line =~ \|[[:space:]]*Completion: ]]; then
        echo "ERR:COMPLETION:missing_marker:$entry"
        return 1
    fi

    # Must have at least one completed criterion with evidence [x] ... (...)
    # Use grep for complex regex (bash [[ ]] has issues with certain patterns)
    if ! echo "$entry" | grep -qE '\[[-x+]\].*\([^)]+\)'; then
        echo "ERR:COMPLETION:missing_evidence:$entry"
        return 1
    fi

    # Check for empty evidence ()
    if echo "$entry" | grep -qE '\[[-x+]\].*\(\)'; then
        echo "ERR:COMPLETION:empty_evidence:$entry"
        return 1
    fi

    return 0
}

# Validate Interaction entry format
# Format: TIMESTAMP | Interaction: [input] -> [outcome]
validate_interaction_entry() {
    local entry="$1"

    # Extract timestamp
    local ts
    ts=$(echo "$entry" | cut -d'|' -f1 | tr -d ' ')
    if ! validate_timestamp "$ts" >/dev/null 2>&1; then
        echo "ERR:INTERACTION:bad_timestamp:$ts"
        return 1
    fi

    # Must have "Interaction:" marker
    if [[ ! $entry =~ \|[[:space:]]*Interaction: ]]; then
        echo "ERR:INTERACTION:missing_marker:$entry"
        return 1
    fi

    # Must have ASCII arrow -> (not unicode)
    if [[ ! $entry =~ Interaction:.*-\> ]]; then
        # Check for unicode arrow
        if [[ $entry =~ Interaction:.*→ ]]; then
            echo "ERR:INTERACTION:unicode_arrow:$entry"
        else
            echo "ERR:INTERACTION:no_arrow:$entry"
        fi
        return 1
    fi

    return 0
}

# Validate Lesson entry format
# Format: TIMESTAMP | Lesson: [title] -> [guide] | [context]
validate_lesson_entry() {
    local entry="$1"

    # Extract timestamp
    local ts
    ts=$(echo "$entry" | cut -d'|' -f1 | tr -d ' ')
    if ! validate_timestamp "$ts" >/dev/null 2>&1; then
        echo "ERR:LESSON:bad_timestamp:$ts"
        return 1
    fi

    # Must have "Lesson:" marker
    if [[ ! $entry =~ \|[[:space:]]*Lesson: ]]; then
        echo "ERR:LESSON:missing_marker:$entry"
        return 1
    fi

    # Must have ASCII arrow -> pointing to guide
    if [[ ! $entry =~ Lesson:.*-\> ]]; then
        echo "ERR:LESSON:no_arrow:$entry"
        return 1
    fi

    return 0
}

# Extract criteria from Contract entry
# Returns one criterion per line
extract_criteria() {
    local entry="$1"
    echo "$entry" | grep -oE '\[ \] [^,|]+' | sed 's/\[ \] //' | sed 's/[[:space:]]*$//'
}

# Validate evidence is non-empty
validate_evidence() {
    local text="$1"
    # Check for empty parens
    if [[ $text =~ \(\) ]]; then
        echo "ERR:EVIDENCE:empty:$text"
        return 1
    fi
    # Check for parens with only whitespace
    if [[ $text =~ \([[:space:]]*\) ]]; then
        echo "ERR:EVIDENCE:whitespace_only:$text"
        return 1
    fi
    return 0
}

# Match criteria between Contract and Completion
# Returns 0 if all Contract criteria appear in Completion with evidence
match_criteria() {
    local contract="$1" completion="$2"

    # Extract criteria from Contract: "[ ] auth" -> "auth"
    local -a contract_criteria
    while IFS= read -r criterion; do
        [[ -n "$criterion" ]] && contract_criteria+=("$criterion")
    done < <(extract_criteria "$contract")

    if [[ ${#contract_criteria[@]} -eq 0 ]]; then
        echo "ERR:CRITERIA:no_criteria:$contract"
        return 1
    fi

    # For each Contract criterion, verify it appears in Completion
    for criterion in "${contract_criteria[@]}"; do
        # Match: [x] criterion (evidence) OR [-] criterion (reason) OR [+] criterion (reason)
        if ! echo "$completion" | grep -qE "\[[-x+]\] ${criterion}.*\([^)]+\)"; then
            echo "ERR:CRITERIA:missing:$criterion"
            return 1
        fi
        # Check for empty evidence
        if echo "$completion" | grep -qE "\[[-x+]\] ${criterion}.*\(\)"; then
            echo "ERR:CRITERIA:no_evidence:$criterion"
            return 1
        fi
    done
    return 0
}

# Validate plan file hierarchy (skeleton/expand/collapse rules)
# Returns 0 if valid, 1 if invalid
validate_plan_hierarchy() {
    local plan_file="$1"

    if [[ ! -f "$plan_file" ]]; then
        echo "ERR:HIERARCHY:file_not_found:$plan_file"
        return 1
    fi

    awk '
    BEGIN { in_collapsed = 0; in_current = 0; first_pending_seen = 0; has_stages = 0 }

    # Detect phase lines by checkbox + "Phase"
    /^\[x\] Phase/ {
        in_collapsed = 1; in_current = 0
        collapsed_line = $0
        next
    }
    /^\[ \] Phase/ {
        if (!first_pending_seen) {
            # First pending = current phase (should be expanded)
            in_current = 1; in_collapsed = 0; first_pending_seen = 1
            current_line = $0
        } else {
            # Subsequent pending = future (should be skeleton)
            in_current = 0; in_collapsed = 0
            future_line = $0
        }
        next
    }

    # Check indented lines (children of phases)
    /^[[:space:]]+\[/ {
        if (in_collapsed) {
            print "ERR:HIERARCHY:collapsed_has_children:" collapsed_line
            exit 1
        }
        if (in_current && /\[.\] (Plan|Implement)/) {
            has_stages = 1
        }
        if (!in_current && !in_collapsed && first_pending_seen && /\[.\] (Plan|Implement)/) {
            print "ERR:HIERARCHY:future_not_skeleton:" future_line
            exit 1
        }
    }

    # Non-indented non-phase line resets context
    /^[^\[[:space:]]/ { in_collapsed = 0 }

    END {
        if (first_pending_seen && !has_stages) {
            print "ERR:HIERARCHY:current_not_expanded:" current_line
            exit 1
        }
    }
    ' "$plan_file"
}
