#!/bin/bash
# Post-tool-use hook - Detect violations
SCRIPT_DIR="${HOME}/.claude/scripts"
CONTEXT_JSON="$1"

if [ -x "$SCRIPT_DIR/detect-violation.sh" ]; then
    "$SCRIPT_DIR/detect-violation.sh" "$CONTEXT_JSON"
fi
