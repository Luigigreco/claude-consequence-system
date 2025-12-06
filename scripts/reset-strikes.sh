#!/bin/bash
# Reset all strikes (admin function)
REGISTRY="${HOME}/.claude/.violation-registry.json"
LOG_FILE="${HOME}/.claude/logs/violations.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ ! -f "$REGISTRY" ]; then
    echo "No registry found."
    exit 0
fi

OLD_STRIKES=$(jq -r '.strikes' "$REGISTRY")

jq --arg ts "$TIMESTAMP" \
   '.strikes = 0 | .successful_tasks = 0 | .consequences_active = [] | .last_reset = $ts' \
   "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"

echo "═══════════════════════════════════════════"
echo "    ✅ STRIKES RESET"
echo "═══════════════════════════════════════════"
echo "Previous: $OLD_STRIKES"
echo "Current:  0"
echo "Time:     $TIMESTAMP"
echo "═══════════════════════════════════════════"

echo "[$TIMESTAMP] RESET | Previous: $OLD_STRIKES" >> "$LOG_FILE"
