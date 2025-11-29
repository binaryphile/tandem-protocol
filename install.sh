#!/usr/bin/env bash
set -e

# Tandem Protocol Installation Script
# Usage: bash /path/to/tandem-protocol/install.sh [--global]
#
# Assumes you've already cloned the repository.
# Script auto-detects its own location - no need to cd or set env vars.
#
# --global: Install to ~/.claude/CLAUDE.md (all projects)
# (default): Install to ./CLAUDE.local.md (current project only)
#
# Override detection: TANDEM_PROTOCOL_DIR=/custom/path bash install.sh

GLOBAL=false
if [[ "$1" == "--global" ]]; then
    GLOBAL=true
fi

echo "🚀 Installing Tandem Protocol..."
echo ""

# Detect protocol directory from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -n "$TANDEM_PROTOCOL_DIR" ]; then
    # Override with env var if provided
    PROTOCOL_DIR="$TANDEM_PROTOCOL_DIR"
    echo "📍 Using TANDEM_PROTOCOL_DIR: $PROTOCOL_DIR"
else
    # Use script's directory
    PROTOCOL_DIR="$SCRIPT_DIR"
    echo "📍 Detected from script location: $PROTOCOL_DIR"
fi

# Verify required files exist
if [ ! -f "$PROTOCOL_DIR/tandem-protocol.md" ]; then
    echo "❌ Error: tandem-protocol.md not found in $PROTOCOL_DIR"
    exit 1
fi

if [ ! -f "$PROTOCOL_DIR/tandem.md" ]; then
    echo "❌ Error: tandem.md not found in $PROTOCOL_DIR"
    exit 1
fi

# Create symlink for /tandem command
COMMANDS_DIR="$HOME/.claude/commands"
echo "🔗 Creating /tandem command symlink..."
mkdir -p "$COMMANDS_DIR"
ln -sf "$PROTOCOL_DIR/tandem.md" "$COMMANDS_DIR/tandem.md"

if [ -L "$COMMANDS_DIR/tandem.md" ]; then
    echo "✅ Symlink created: $COMMANDS_DIR/tandem.md"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

# Determine target CLAUDE.md file
if [ "$GLOBAL" = true ]; then
    CLAUDE_FILE="$HOME/.claude/CLAUDE.md"
    SCOPE="global (all projects)"
else
    CLAUDE_FILE="./CLAUDE.local.md"
    SCOPE="local (current project only)"
fi

# Convert protocol directory to relative path using tilde if in home directory
PROTOCOL_REF="$PROTOCOL_DIR"
if [[ "$PROTOCOL_DIR" == "$HOME"* ]]; then
    PROTOCOL_REF="~${PROTOCOL_DIR#$HOME}"
fi

REFERENCE_LINE="@$PROTOCOL_REF/tandem-protocol.md"

# Check if CLAUDE file exists
if [ -f "$CLAUDE_FILE" ]; then
    # Check if reference already exists
    if grep -Fq "$REFERENCE_LINE" "$CLAUDE_FILE"; then
        echo "ℹ️  Reference already exists in $CLAUDE_FILE"
        echo "✅ Installation complete!"
        exit 0
    fi

    # Append to existing file
    echo "📝 Adding reference to existing $CLAUDE_FILE..."
    echo "" >> "$CLAUDE_FILE"
    echo "# Tandem Protocol" >> "$CLAUDE_FILE"
    echo "$REFERENCE_LINE" >> "$CLAUDE_FILE"
else
    # Create new file
    echo "📝 Creating $CLAUDE_FILE..."
    mkdir -p "$(dirname "$CLAUDE_FILE")"
    cat > "$CLAUDE_FILE" <<EOF
# Tandem Protocol
$REFERENCE_LINE
EOF
fi

echo "✅ Installation complete!"
echo ""
echo "📋 Installation summary:"
echo "   Scope: $SCOPE"
echo "   CLAUDE file: $CLAUDE_FILE"
echo "   Reference: $REFERENCE_LINE"
echo ""
echo "🔍 Verify: Start Claude Code in your project, then run /tandem"
echo ""
