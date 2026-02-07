#!/bin/bash
# Extract tool calls from Claude Code JSONL transcript

# Usage: transcript-parser.sh <transcript.jsonl> <tool_name> [pattern]
# Returns: Lines containing tool invocations matching criteria

TRANSCRIPT="$1"
TOOL_NAME="$2"
PATTERN="${3:-.*}"

if [[ -z "$TRANSCRIPT" || -z "$TOOL_NAME" ]]; then
    echo "Usage: $0 <transcript.jsonl> <tool_name> [pattern]" >&2
    exit 1
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
    echo "Error: Transcript not found: $TRANSCRIPT" >&2
    exit 1
fi

# Extract tool calls from JSONL
# Tool calls appear in assistant messages with tool_use content blocks
grep -o "\"name\":\"$TOOL_NAME\"[^}]*}" "$TRANSCRIPT" | grep -E "$PATTERN"
