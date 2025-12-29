# Installing the Pre-Emptive Hook

## The Problem: "Groundhog Day"

Claude keeps forgetting to use agents when you type "mm". You ask, Claude responds directly, you remind, Claude apologizes and does it right. Repeat forever.

**Why?** All existing controls are POST-HOC (detect after error). We need PRE-EMPTIVE (prevent before error).

## The Solution: user-prompt-submit Hook

Claude Code supports hooks that intercept **BEFORE** Claude processes your message.

### Step 1: Copy the Hook

```bash
# Copy to Claude's hooks directory
cp hooks/user-prompt-submit.sh ~/.claude/hooks/

# Make executable
chmod +x ~/.claude/hooks/user-prompt-submit.sh
```

### Step 2: Configure Claude Code

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "user-prompt-submit": [
      {
        "command": "~/.claude/hooks/user-prompt-submit.sh \"$PROMPT\""
      }
    ]
  }
}
```

### Step 3: Restart Claude Code

```bash
# Exit and restart Claude Code
# The hook will now intercept every message
```

## How It Works

```
BEFORE (POST-HOC):
User: "mm analyze"
Claude: *responds directly* ❌
detect-violation.sh: "You violated!" → Strike
User: "Try again"
Claude: *now uses agents* ✓
→ Wasted time, frustration

AFTER (PRE-EMPTIVE):
User: "mm analyze"
Hook: ╔═══ MM MODE INTERCEPTED ═══╗
      ║ MUST use Task tool...     ║
      ╚═══════════════════════════╝
Claude: *sees warning, uses Task tool* ✓
→ Correct behavior first time
```

## Verification

Test with:
```
mm test
```

You should see the intercept banner BEFORE Claude responds.

## Troubleshooting

**Hook not triggering?**
- Check permissions: `ls -la ~/.claude/hooks/`
- Verify settings.json syntax
- Restart Claude Code

**Still bypassing?**
- Check `~/.claude/scripts/check-strikes.sh` for strike count
- Reset if needed: `~/.claude/scripts/reset-strikes.sh`

## Research Basis

Based on NSR (Negative Sample Reinforcement) research:
- Prevention is more effective than punishment
- Intercepting before error > detecting after error
- Visual warning creates immediate context

See: [ArXiv 2506.01347](https://arxiv.org/abs/2506.01347)
