#!/bin/bash
# Add a strike for a violation
REGISTRY="${HOME}/.claude/.violation-registry.json"
LOG_FILE="${HOME}/.claude/logs/violations.log"

VIOLATION_TYPE="${1:-unknown}"
DESCRIPTION="${2:-No description}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$LOG_FILE")"

# Add violation
jq --arg type "$VIOLATION_TYPE" --arg desc "$DESCRIPTION" --arg ts "$TIMESTAMP" \
   '.strikes += 1 | .successful_tasks = 0 | .violations += [{"type": $type, "description": $desc, "timestamp": $ts}]' \
   "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"

STRIKES=$(jq -r '.strikes' "$REGISTRY")

echo "═══════════════════════════════════════════"
echo "    ⚠️  VIOLATION RECORDED"
echo "═══════════════════════════════════════════"
echo "Type:    $VIOLATION_TYPE"
echo "Desc:    $DESCRIPTION"
echo "Strikes: $STRIKES / 3"

if [ "$STRIKES" -ge 3 ]; then
    echo ""
    echo "⛔ CONSEQUENCE: TOOL LOCKDOWN ACTIVATED"
elif [ "$STRIKES" -ge 2 ]; then
    echo ""
    echo "⚠️  CONSEQUENCE: CONTEXT COMPRESSION"
fi
echo "═══════════════════════════════════════════"

echo "[$TIMESTAMP] STRIKE +1 | $VIOLATION_TYPE | $DESCRIPTION" >> "$LOG_FILE"
