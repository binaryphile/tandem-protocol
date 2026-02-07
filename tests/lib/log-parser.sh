#!/bin/bash
# Parse plan-log.md for entry format compliance

# Usage: log-parser.sh <plan-log.md> <entry_type>
# Entry types: Contract, Completion, Interaction
# Returns: Matching entries

LOG_FILE="$1"
ENTRY_TYPE="$2"

if [[ -z "$LOG_FILE" || -z "$ENTRY_TYPE" ]]; then
    echo "Usage: $0 <plan-log.md> <entry_type>" >&2
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file not found: $LOG_FILE" >&2
    exit 1
fi

# Extract entries by type
# Format: TIMESTAMP | Type: description
grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z \| $ENTRY_TYPE:" "$LOG_FILE"
