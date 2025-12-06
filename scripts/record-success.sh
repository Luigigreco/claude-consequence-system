#!/bin/bash
# Record successful task (for reward mechanism)
REGISTRY="${HOME}/.claude/.violation-registry.json"

jq '.successful_tasks += 1' "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"

SUCCESS=$(jq -r '.successful_tasks' "$REGISTRY")
STRIKES=$(jq -r '.strikes' "$REGISTRY")

if [ "$SUCCESS" -ge 3 ] && [ "$STRIKES" -gt 0 ]; then
    jq '.strikes -= 1 | .successful_tasks = 0' "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"
    echo "🎉 REWARD: Strike reduced! ($STRIKES → $((STRIKES-1)))"
else
    echo "✅ Task recorded. $((3 - SUCCESS)) more for strike reduction."
fi
