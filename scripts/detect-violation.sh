#!/bin/bash
# Detect violations in Claude's behavior
CONTEXT="$1"
SCRIPT_DIR="$(dirname "$0")"

TOOL_NAME=$(echo "$CONTEXT" | jq -r '.tool_name // "unknown"')
USER_PROMPT=$(echo "$CONTEXT" | jq -r '.user_prompt // ""')
RESPONSE=$(echo "$CONTEXT" | jq -r '.assistant_response // ""')

# Check 1: Mister bypass (mm keyword but no Task tool)
if echo "$USER_PROMPT" | grep -qi "\bmm\b"; then
    if [ "$TOOL_NAME" != "Task" ]; then
        "$SCRIPT_DIR/add-strike.sh" "mister_bypass" "mm requested but Task not used"
        exit 1
    fi
fi

# Check 2: Mock data patterns
if echo "$RESPONSE" | grep -qiE "(mock|fake|dummy|test@example|lorem ipsum)"; then
    "$SCRIPT_DIR/add-strike.sh" "mock_data" "Mock data detected in response"
    exit 1
fi

exit 0
