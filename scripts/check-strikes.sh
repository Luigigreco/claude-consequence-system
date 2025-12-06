#!/bin/bash
# Check current strike status
REGISTRY="${HOME}/.claude/.violation-registry.json"

if [ ! -f "$REGISTRY" ]; then
    echo "No violation registry found."
    exit 0
fi

STRIKES=$(jq -r '.strikes' "$REGISTRY")
MAX=$(jq -r '.max_strikes' "$REGISTRY")
SUCCESS=$(jq -r '.successful_tasks' "$REGISTRY")

echo "═══════════════════════════════════════════"
echo "    CLAUDE CONSEQUENCE SYSTEM STATUS"
echo "═══════════════════════════════════════════"
echo "Strikes:     $STRIKES / $MAX"
echo "Good tasks:  $SUCCESS (need 3 for -1 strike)"
echo ""

if [ "$STRIKES" -ge 3 ]; then
    echo "⛔ STATUS: TOOL LOCKDOWN ACTIVE"
elif [ "$STRIKES" -ge 2 ]; then
    echo "⚠️  STATUS: CONTEXT COMPRESSION ACTIVE"
elif [ "$STRIKES" -ge 1 ]; then
    echo "⚡ STATUS: WARNING LEVEL"
else
    echo "✅ STATUS: CLEAN"
fi

echo ""
echo "Recent violations:"
jq -r '.violations[-3:] | .[] | "  - [\(.timestamp)] \(.type)"' "$REGISTRY" 2>/dev/null || echo "  None"
echo "═══════════════════════════════════════════"
