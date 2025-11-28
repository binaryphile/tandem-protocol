#!/usr/bin/env bash
set -e

# Tandem Protocol Installation Script
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/tandem-protocol/main/install.sh)
#        or: bash install.sh

REPO_URL="${TANDEM_REPO_URL:-https://github.com/YOUR_ORG/tandem-protocol.git}"
INSTALL_DIR="${TANDEM_INSTALL_DIR:-$HOME/tandem-protocol}"
COMMANDS_DIR="$HOME/.claude/commands"

echo "🚀 Installing Tandem Protocol..."
echo ""

# Check if already installed
if [ -d "$INSTALL_DIR/.git" ] || [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Tandem Protocol already exists at: $INSTALL_DIR"
    read -p "Update existing installation? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Updating..."
        if [ -d "$INSTALL_DIR/.git" ]; then
            cd "$INSTALL_DIR" && git pull
        else
            echo "ℹ️  Directory exists but is not a git repository"
        fi
    else
        echo "ℹ️  Skipping installation."
    fi
else
    echo "📦 Installing from: $REPO_URL"
    # Check if REPO_URL is a local directory
    if [ -d "$REPO_URL" ]; then
        echo "📁 Copying from local directory..."
        cp -r "$REPO_URL" "$INSTALL_DIR"
    else
        echo "📦 Cloning repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
fi

# Create symlink
echo "🔗 Creating command symlink..."
mkdir -p "$COMMANDS_DIR"
ln -sf "$INSTALL_DIR/tandem.md" "$COMMANDS_DIR/tandem.md"

# Verify
if [ -L "$COMMANDS_DIR/tandem.md" ] && [ -f "$INSTALL_DIR/tandem.md" ]; then
    echo "✅ Symlink created: $COMMANDS_DIR/tandem.md"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

# Generate CLAUDE.md snippet
echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next step: Add this line to your project's CLAUDE.md:"
echo ""
echo "    @~/tandem-protocol/tandem-protocol.md"
echo ""
echo "💡 Tip: Run this in your project directory:"
echo ""
echo "    echo '' >> CLAUDE.md"
echo "    echo '# Tandem Protocol' >> CLAUDE.md"
echo "    echo '@~/tandem-protocol/tandem-protocol.md' >> CLAUDE.md"
echo ""
echo "🔍 Verify: Start Claude Code in your project, then run /tandem"
echo ""
