# Installation Guide

## Quick Install

```bash
git clone https://github.com/Luigigreco/claude-consequence-system.git
cd claude-consequence-system
./install.sh
```

## Manual Install

1. Copy files:
```bash
cp .violation-registry.json ~/.claude/
cp scripts/* ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh
```

2. Add hooks to `~/.claude/settings.json`:

In `PreToolUse.hooks` array, add:
```json
{
  "type": "command",
  "command": "TOOL=$(echo $CLAUDE_CONTEXT | jq -r '.tool_name // \"\"'); ~/.claude/scripts/check-strikes.sh 2>/dev/null | grep -q 'LOCKDOWN' && [ \"$TOOL\" = \"Task\" ] && echo 'BLOCKED: Tool lockdown active' && exit 1 || exit 0"
}
```

In `PostToolUse.hooks` array, add:
```json
{
  "type": "command", 
  "command": "echo $CLAUDE_CONTEXT | ~/.claude/scripts/detect-violation.sh 2>/dev/null || true"
}
```

3. Restart Claude Code

## Verify Installation

```bash
~/.claude/scripts/check-strikes.sh
```
