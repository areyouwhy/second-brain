#!/bin/bash
set -e

echo "=== Second Brain Setup ==="
echo ""

# Get vault name
read -p "Vault name (this becomes your Obsidian vault name): " VAULT_NAME
if [ -z "$VAULT_NAME" ]; then
  echo "Error: vault name is required"
  exit 1
fi

# Get vault path
read -p "Vault path [~/Documents/projects/$VAULT_NAME]: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$HOME/Documents/projects/$VAULT_NAME}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

echo ""
echo "Vault name: $VAULT_NAME"
echo "Vault path: $VAULT_PATH"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Create vault directory and scaffold
echo ""
echo "Creating vault structure..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$VAULT_PATH" ]; then
  mkdir -p "$VAULT_PATH"
fi

# Copy scaffold (don't overwrite existing files)
cp -rn "$SCRIPT_DIR/vault-scaffold/"* "$VAULT_PATH/" 2>/dev/null || true
cp -rn "$SCRIPT_DIR/vault-scaffold/".* "$VAULT_PATH/" 2>/dev/null || true

# Remove .gitkeep files (they were just to preserve empty dirs in git)
find "$VAULT_PATH" -name ".gitkeep" -delete 2>/dev/null || true

echo "  Vault structure created at $VAULT_PATH"

# Install commands
echo ""
echo "Installing Claude Code commands..."
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

for file in "$SCRIPT_DIR/commands/"*.md; do
  filename=$(basename "$file")
  sed "s/{{VAULT_NAME}}/$VAULT_NAME/g" "$file" > "$COMMANDS_DIR/$filename"
  echo "  Installed /$(basename "$filename" .md)"
done

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Open Obsidian and add $VAULT_PATH as a vault"
echo "  2. Fill in the notes in Me/ with your personal context"
echo "  3. Install the obsidian-skills plugin (for the obsidian CLI):"
echo "     claude install obsidian-skills"
echo "  4. Start a Claude Code session and run /context-me to test"
echo ""
echo "Available commands:"
echo "  /context        — Smart context loader (auto-detects your project)"
echo "  /context-me     — Load just your identity"
echo "  /context-work   — Load work & career context"
echo "  /context-project — Deep project context"
echo "  /context-all    — Load everything"
echo "  /today          — Daily planning with calendar + tasks"
echo "  /end-session    — Wrap up a project session"
echo "  /end-day        — End-of-day aggregation"
echo "  /update-context-dependencies — Maintain project dependencies"
echo "  /trace <topic>  — Trace an idea's evolution"
