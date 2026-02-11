#!/bin/bash
# session-branch.sh - Create a branched session from an existing checkpoint
#
# Usage: session-branch.sh <source-session-id> <checkpoint-uuid> <new-user-message> [cwd] [project-dir]
#
# This creates a new session that branches from an existing session at a specific
# message, allowing tests to start from a known state instead of replaying.

set -euo pipefail

SOURCE_SESSION="$1"
CHECKPOINT_UUID="$2"
NEW_MESSAGE="$3"
BRANCH_CWD="${4:-/home/ted/projects/tandem-protocol}"
PROJECT_DIR="${5:-}"

# Find session file - try explicit project dir first, then search
if [[ -n "$PROJECT_DIR" && -f "$PROJECT_DIR/$SOURCE_SESSION.jsonl" ]]; then
    SOURCE_FILE="$PROJECT_DIR/$SOURCE_SESSION.jsonl"
else
    # Search for session file
    SOURCE_FILE=$(find ~/.claude/projects -name "$SOURCE_SESSION.jsonl" 2>/dev/null | head -1)
fi

if [[ -z "$SOURCE_FILE" || ! -f "$SOURCE_FILE" ]]; then
    echo "ERROR: Source session not found: $SOURCE_SESSION" >&2
    exit 1
fi

SOURCE_PROJECT_DIR=$(dirname "$SOURCE_FILE")

# Generate new session ID (use /proc/sys/kernel/random/uuid if uuidgen unavailable)
if command -v uuidgen &>/dev/null; then
    NEW_SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
    NEW_SESSION_ID=$(cat /proc/sys/kernel/random/uuid)
fi

# Determine target project directory based on branch cwd
# Claude Code encodes paths: /home/ted/foo -> -home-ted-foo
TARGET_PROJECT_DIR="$HOME/.claude/projects/$(echo "$BRANCH_CWD" | sed 's|/|-|g')"
mkdir -p "$TARGET_PROJECT_DIR"

NEW_FILE="$TARGET_PROJECT_DIR/$NEW_SESSION_ID.jsonl"

# Find line number of checkpoint message
CHECKPOINT_LINE=$(grep -n "\"uuid\":\"$CHECKPOINT_UUID\"" "$SOURCE_FILE" | tail -1 | cut -d: -f1)

if [[ -z "$CHECKPOINT_LINE" ]]; then
    echo "ERROR: Checkpoint UUID not found: $CHECKPOINT_UUID" >&2
    exit 1
fi

echo "Branching from $SOURCE_SESSION at line $CHECKPOINT_LINE (uuid: $CHECKPOINT_UUID)"

# Copy session up to and including checkpoint
head -n "$CHECKPOINT_LINE" "$SOURCE_FILE" > "$NEW_FILE"

# Update sessionId in copied lines
sed -i "s/$SOURCE_SESSION/$NEW_SESSION_ID/g" "$NEW_FILE"

# Update cwd in all messages to branch workspace
# Extract original cwd from first user message
ORIGINAL_CWD=$(grep '"type":"user"' "$NEW_FILE" | head -1 | jq -r '.cwd // empty' 2>/dev/null || true)
if [[ -n "$ORIGINAL_CWD" && "$ORIGINAL_CWD" != "$BRANCH_CWD" ]]; then
    # Escape special characters for sed
    ESCAPED_ORIG=$(printf '%s\n' "$ORIGINAL_CWD" | sed 's/[[\.*^$()+?{|]/\\&/g')
    ESCAPED_NEW=$(printf '%s\n' "$BRANCH_CWD" | sed 's/[[\.*^$()+?{|]/\\&/g')
    sed -i "s|$ESCAPED_ORIG|$ESCAPED_NEW|g" "$NEW_FILE"
fi

# Generate new user message UUID
if command -v uuidgen &>/dev/null; then
    NEW_MSG_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
    NEW_MSG_UUID=$(cat /proc/sys/kernel/random/uuid)
fi
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# Append new user message
cat >> "$NEW_FILE" << EOF
{"parentUuid":"$CHECKPOINT_UUID","isSidechain":true,"userType":"external","cwd":"$BRANCH_CWD","sessionId":"$NEW_SESSION_ID","version":"2.1.25","gitBranch":"main","type":"user","message":{"role":"user","content":"$NEW_MESSAGE"},"uuid":"$NEW_MSG_UUID","timestamp":"$TIMESTAMP","permissionMode":"default"}
EOF

echo "Created branched session: $NEW_SESSION_ID"
echo "File: $NEW_FILE"
echo "Lines: $(wc -l < "$NEW_FILE")"
echo ""
echo "Resume with: claude --resume $NEW_SESSION_ID"
