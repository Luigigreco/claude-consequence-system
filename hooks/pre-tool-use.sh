#!/bin/bash
# Pre-tool-use hook - Block tools if strikes >= 3
REGISTRY="${HOME}/.claude/.violation-registry.json"
TOOL_NAME="$1"

if [ ! -f "$REGISTRY" ]; then exit 0; fi

STRIKES=$(jq -r '.strikes' "$REGISTRY" 2>/dev/null || echo "0")

if [ "$STRIKES" -ge 3 ] && [ "$TOOL_NAME" = "Task" ]; then
    echo "═══════════════════════════════════════════"
    echo "    ⛔ TOOL BLOCKED: LOCKDOWN ACTIVE"
    echo "═══════════════════════════════════════════"
    echo "Strikes: $STRIKES / 3"
    echo "Task tool disabled for 10 minutes."
    echo ""
    echo "Options:"
    echo "  1. Wait 10 minutes"
    echo "  2. Admin reset: ~/.claude/scripts/reset-strikes.sh"
    echo "═══════════════════════════════════════════"
    exit 1
fi

if [ "$STRIKES" -ge 2 ]; then
    echo "⚠️  Context compression active. Be concise."
fi

exit 0
