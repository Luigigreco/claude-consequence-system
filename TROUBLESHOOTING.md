# Troubleshooting Guide

## Permission Errors on Registry Files

### Error: "Operation not permitted" on `.violation-registry.json`

**Cause**: macOS extended attributes (`com.apple.provenance`) prevent file access from Claude Code.

**Solution 1 (Recommended): Use V2 Registry Files**

The consequence system V2.0+ uses simplified JSON files without extended attributes:

```bash
# Check current registry version
cat ~/.claude/.violation-registry.json | head -3

# If version < 2.0, migrate to V2
~/.claude/scripts/migrate-registry-v2.sh
```

**Solution 2: Remove Extended Attributes**

If you must use the current file:

```bash
# Check for extended attributes
xattr -l ~/.claude/.violation-registry.json

# Remove all extended attributes
xattr -c ~/.claude/.violation-registry.json

# Verify removal
xattr -l ~/.claude/.violation-registry.json
# (Should output nothing)
```

**Solution 3: Recreate Registry**

```bash
# Backup current registry
cp ~/.claude/.violation-registry.json ~/.claude/.violation-registry.json.backup

# Remove problematic file
rm ~/.claude/.violation-registry.json

# Reinitialize (creates clean V2 registry)
~/.claude/scripts/init-consequence-system.sh
```

---

## Missing `jq` Utility

### Error: `jq: command not found`

The consequence system requires `jq` for JSON parsing.

**Quick Fix**:

```bash
# Install jq via Homebrew
brew install jq

# Verify installation
jq --version
# Output: jq-1.7.1 (or similar)
```

**Alternative: MacPorts**

```bash
sudo port install jq
```

**Verify Integration**:

```bash
# Test jq with consequence system
~/.claude/scripts/check-strikes.sh

# Should display strike count without errors
```

---

## Hooks Not Executing

### Problem: Consequence system doesn't trigger on violations

**Step 1: Verify Hook Configuration**

Check your `settings.json` (Claude desktop app):

```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep -A 10 "consequences"
```

**Step 2: Example Correct Configuration**

```json
{
  "mcpServers": {
    "consequence-system": {
      "command": "bash",
      "args": [
        "-c",
        "source ~/.claude/scripts/consequence-hooks.sh"
      ]
    }
  },
  "tools": {
    "hooks": {
      "pre-prompt": "check-violation-rules.sh",
      "post-execution": "record-violation.sh"
    }
  }
}
```

**Step 3: Re-enable Hooks**

```bash
# Install/reinstall hooks
~/.claude/scripts/install-consequence-hooks.sh

# Verify installation
ls -la ~/.claude/hooks/
# Should show: pre-*.sh, post-*.sh files
```

**Step 4: Test Hook Execution**

```bash
# Manual hook test
bash ~/.claude/hooks/pre-violation-check.sh

# Check hook logs
tail -20 ~/.claude/logs/hooks.log
```

---

## Registry Corruption Recovery

### Error: Invalid JSON in `.violation-registry.json`

**Quick Validation**:

```bash
# Validate JSON syntax
jq . ~/.claude/.violation-registry.json > /dev/null

# If error: "parse error", proceed to recovery
```

**Recovery Steps**:

```bash
# 1. Backup corrupted file
cp ~/.claude/.violation-registry.json ~/.claude/.violation-registry.json.corrupted

# 2. Check backup
ls -la ~/.claude/.violation-registry.json*

# 3. Restore from backup (if available)
if [ -f ~/.claude/.violation-registry.json.backup ]; then
  cp ~/.claude/.violation-registry.json.backup ~/.claude/.violation-registry.json
  echo "Restored from backup"
fi

# 4. If no backup, reinitialize clean
rm ~/.claude/.violation-registry.json
~/.claude/scripts/init-consequence-system.sh

# 5. Verify recovery
~/.claude/scripts/check-strikes.sh
```

**Prevent Future Corruption**:

```bash
# Enable atomic writes (prevents partial file writes)
export CONSEQUENCE_ATOMIC_WRITES=true

# Enable automatic backups (kept last 5 versions)
export CONSEQUENCE_AUTO_BACKUP=true
~/.claude/scripts/enable-auto-backup.sh
```

---

## Strike Counting Issues

### Strike count doesn't increment or decrements unexpectedly

**Diagnosis**:

```bash
# Check violation log
tail -50 ~/.claude/logs/violations.log

# View recent violations
grep "VIOLATION" ~/.claude/logs/violations.log | tail -10

# Check strike calculation
~/.claude/scripts/debug-strikes.sh
```

**Manual Strike Management**:

```bash
# View current strikes
~/.claude/scripts/check-strikes.sh

# Add strike manually
~/.claude/scripts/add-strike.sh "violation_type" "description"

# Record successful task (reduces strikes by 1)
~/.claude/scripts/record-success.sh

# Reset strikes to 0 (admin only)
~/.claude/scripts/reset-strikes.sh
```

---

## Reward System Not Working

### Successful tasks not reducing strikes

**Verification**:

```bash
# Check success count
grep "SUCCESS" ~/.claude/logs/violations.log | wc -l

# View success threshold
grep "tasks_for_reward" ~/.claude/.violation-registry.json

# Expected: 3 successes = -1 strike
```

**Manual Reward**:

```bash
# Record success (if not auto-detecting)
~/.claude/scripts/record-success.sh

# Check updated strikes
~/.claude/scripts/check-strikes.sh

# Should decrease by 1 after 3 successful tasks
```

---

## Auto-Reset Not Triggering (24-hour reset)

### Strikes not resetting after 24 hours

**Check Reset Configuration**:

```bash
# View reset interval setting
jq '.reset_interval_hours' ~/.claude/.violation-registry.json

# Should be: 24
```

**Manual Reset Trigger**:

```bash
# Check last reset time
jq '.last_reset' ~/.claude/.violation-registry.json

# Manually trigger reset
~/.claude/scripts/reset-strikes.sh

# Verify reset
~/.claude/scripts/check-strikes.sh
```

---

## Debugging Tips

### Enable verbose logging

```bash
# Run any consequence script with debug output
DEBUG=1 ~/.claude/scripts/check-strikes.sh

# Tail live logs
tail -f ~/.claude/logs/hooks.log

# Combine logs for full picture
grep -r "VIOLATION\|SUCCESS\|STRIKE" ~/.claude/logs/ | tail -30
```

### System health check

```bash
# Run complete diagnostic
~/.claude/scripts/consequence-health-check.sh

# Output includes:
# - File permissions
# - jq availability
# - Hook installation status
# - Registry validity
# - Recent violations
```

---

## Still Having Issues?

**Self-Service Resources**:

1. Check logs first: `~/.claude/logs/violations.log`
2. Run health check: `~/.claude/scripts/consequence-health-check.sh`
3. Review source: `https://github.com/Luigigreco/claude-consequence-system`
4. Reset cleanly: `rm ~/.claude/.violation-registry.json && init-consequence-system.sh`

**Environment Information**:

When diagnosing, collect:
- macOS version: `sw_vers`
- Bash version: `bash --version`
- jq version: `jq --version`
- Hook logs: `tail -50 ~/.claude/logs/hooks.log`
- Registry version: `jq '.version' ~/.claude/.violation-registry.json`
