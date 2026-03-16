#!/usr/bin/env bash
# setup.sh -- Bootstrap all agents for a new Paperclip company
# Usage: bash setup.sh <company_id>
#
# This script creates the agent home directories and symlinks AGENTS.md
# as the instruction file for each agent role defined in default/.
# Run this once when setting up a new company instance.

set -euo pipefail

COMPANY_ID="${1:-}"
if [[ -z "$COMPANY_ID" ]]; then
  echo "Usage: bash setup.sh <company_id>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_DIR="$SCRIPT_DIR/default"
AGENTS_ROOT="$SCRIPT_DIR/agents"

# Roles to bootstrap -- matches folders under default/
ROLES=(ceo ba pm engineer)

echo "==> Bootstrapping agents for company: $COMPANY_ID"
echo ""

for ROLE in "${ROLES[@]}"; do
  TEMPLATE_DIR="$DEFAULT_DIR/$ROLE"
  AGENT_DIR="$AGENTS_ROOT/$ROLE"

  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "[SKIP] No template found for role: $ROLE (expected $TEMPLATE_DIR)"
    continue
  fi

  echo "[SETUP] $ROLE"

  # Create agent home directory structure
  mkdir -p "$AGENT_DIR/memory"
  mkdir -p "$AGENT_DIR/life"

  # Copy template files into agent home
  for FILE in AGENTS.md HEARTBEAT.md SOUL.md TOOLS.md; do
    SRC="$TEMPLATE_DIR/$FILE"
    DST="$AGENT_DIR/$FILE"
    if [[ -f "$SRC" ]]; then
      cp "$SRC" "$DST"
      echo "  copied $FILE"
    else
      echo "  [WARN] missing $FILE in template"
    fi
  done

  # Set AGENT_HOME in each file so the agent knows its own path
  if command -v sed &>/dev/null; then
    sed -i.bak "s|\$AGENT_HOME|$AGENT_DIR|g" "$AGENT_DIR/AGENTS.md" 2>/dev/null || true
    sed -i.bak "s|\$AGENT_HOME|$AGENT_DIR|g" "$AGENT_DIR/HEARTBEAT.md" 2>/dev/null || true
    rm -f "$AGENT_DIR"/*.bak
  fi

  # Write agent environment file
  cat > "$AGENT_DIR/.env" <<EOF
AGENT_ROLE=$ROLE
AGENT_HOME=$AGENT_DIR
COMPANY_ID=$COMPANY_ID
AGENTS_INSTRUCTION_FILE=$AGENT_DIR/AGENTS.md
EOF

  echo "  AGENTS_INSTRUCTION_FILE => $AGENT_DIR/AGENTS.md"
  echo ""
done

echo "==> Done. Agent directories created under: $AGENTS_ROOT"
echo ""
echo "Next steps:"
echo "  1. Set AGENT_HOME and COMPANY_ID in each agent's runtime environment."
echo "  2. Point each agent's instruction file to agents/<role>/AGENTS.md."
echo "  3. Start with the CEO: agents/ceo/AGENTS.md"
