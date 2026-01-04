# macOS Installation Guide

Complete setup instructions for claude-consequence-system on macOS, including solutions for common permission and extended attribute issues.

## Quick Start (5 minutes)

### 1. Install Required Dependencies

```bash
# Install jq (JSON query tool - required for all scripts)
brew install jq

# Verify installation
jq --version
```

### 2. Clone Repository

```bash
git clone https://github.com/Luigigreco/claude-consequence-system.git
cd claude-consequence-system
```

### 3. Run Installation

```bash
# Standard installation
./install.sh

# OR manual installation
mkdir -p ~/.claude/scripts
mkdir -p ~/.claude/hooks
cp scripts/* ~/.claude/scripts/
cp hooks/* ~/.claude/hooks/
chmod +x ~/.claude/scripts/*.sh
chmod +x ~/.claude/hooks/*.sh
cp .violation-registry.json ~/.claude/
```

### 4. Verify Installation

```bash
~/.claude/scripts/check-strikes.sh
```

You should see:
```
═══════════════════════════════════════════
    CLAUDE CONSEQUENCE SYSTEM STATUS
═══════════════════════════════════════════
Strikes:     0 / 3
Good tasks:  0 (need 3 for -1 strike)

✅ STATUS: CLEAN
```

---

## Common macOS Issues & Solutions

### Issue 1: "Operation not permitted" When Adding Strikes

**Problem:** When running scripts, you see:
```
-bash: permission denied: ~/.claude/scripts/add-strike.sh
Operation not permitted
```

**Root Cause:** macOS System Integrity Protection (SIP) or extended attributes blocking script execution.

**Solution - Use v2 Scripts:**

The repository includes v2 versions of all scripts optimized for macOS. These handle extended attributes automatically:

```bash
# Use v2 versions (automatically handles permissions)
~/.claude/scripts/add-strike-v2.sh TYPE "description"
~/.claude/scripts/check-strikes-v2.sh
~/.claude/scripts/record-success-v2.sh
```

**What v2 does:**
- Strips extended attributes automatically
- Uses POSIX-compliant JSON handling
- Works with macOS Sequoia and older versions
- No sudo required

### Issue 2: Extended Attributes Blocking Writes

**Problem:** Scripts fail with:
```
xattr: com.apple.quarantine: No such file or directory
cannot write to file: not permitted
```

**Solution - Manual Attribute Removal:**

If v2 scripts don't solve it, manually clean attributes:

```bash
# Remove quarantine attribute from all scripts
xattr -d com.apple.quarantine ~/.claude/scripts/*.sh
xattr -d com.apple.quarantine ~/.claude/hooks/*.sh

# Remove all extended attributes
xattr -c ~/.claude/scripts/*.sh
xattr -c ~/.claude/hooks/*.sh

# Verify (should show empty output)
xattr ~/.claude/scripts/check-strikes.sh
```

**Why this happens:** macOS adds quarantine attributes when downloading from the internet. This blocks execution by default.

### Issue 3: Permission "Denied" on File Access

**Problem:** Scripts fail when accessing `.violation-registry.json`:
```
jq: cannot open /Users/username/.claude/.violation-registry.json: Permission denied
```

**Solution:**

```bash
# Fix file permissions
chmod 644 ~/.claude/.violation-registry.json

# Fix directory permissions (if needed)
chmod 755 ~/.claude/
chmod 755 ~/.claude/scripts/
chmod 755 ~/.claude/hooks/

# Verify with ls -la
ls -la ~/.claude/.violation-registry.json
# Should show: -rw-r--r-- (644 permissions)
```

---

## Permission Troubleshooting with xattr Commands

### Complete xattr Troubleshooting Flow

If you encounter any permission issues, run this diagnostic:

```bash
# 1. Check what attributes are blocking files
xattr ~/.claude/scripts/check-strikes.sh

# 2. Remove specific problematic attribute
xattr -d com.apple.quarantine ~/.claude/scripts/check-strikes.sh

# 3. Remove ALL extended attributes from directory
find ~/.claude -type f -name "*.sh" -exec xattr -c {} \;

# 4. Verify all attributes removed
find ~/.claude -type f -name "*.sh" -exec xattr {} \;
# Should show nothing if successful

# 5. Re-apply execute permissions
chmod +x ~/.claude/scripts/*.sh
chmod +x ~/.claude/hooks/*.sh

# 6. Test
~/.claude/scripts/check-strikes.sh
```

### Advanced: Recursive Fix for Entire Directory

If multiple files are problematic:

```bash
# Nuclear option - clean everything
xattr -cr ~/.claude/

# Re-apply permissions
find ~/.claude -type f -name "*.sh" -exec chmod +x {} \;
find ~/.claude -type f -name "*.json" -exec chmod 644 {} \;

# Verify
file ~/.claude/scripts/check-strikes.sh
# Should show: Bourne-Again shell script, ASCII text executable
```

---

## Verification Steps

### Step 1: Verify Dependencies

```bash
# Check jq installation
jq --version

# Check bash version (should be 4.0+)
bash --version

# Verify git
git --version
```

### Step 2: Verify File Structure

```bash
# Check all required files exist
ls -la ~/.claude/.violation-registry.json
ls -la ~/.claude/scripts/
ls -la ~/.claude/hooks/

# Expected output:
# scripts/: check-strikes.sh, add-strike.sh, reset-strikes.sh, record-success.sh
# hooks/:   pre-tool-use.sh, post-tool-use.sh
```

### Step 3: Verify Permissions

```bash
# Check script permissions (should be -rwxr-xr-x)
ls -la ~/.claude/scripts/check-strikes.sh

# Check registry permissions (should be -rw-r--r--)
ls -la ~/.claude/.violation-registry.json

# If permissions wrong, fix:
chmod +x ~/.claude/scripts/*.sh
chmod 644 ~/.claude/.violation-registry.json
```

### Step 4: Test Functionality

```bash
# Test basic functionality
~/.claude/scripts/check-strikes.sh

# Test JSON processing
jq '.strikes' ~/.claude/.violation-registry.json

# Test strike operation (optional)
~/.claude/scripts/add-strike.sh "test_violation" "test description"
```

---

## Workaround Scripts Usage

The v2 workaround scripts handle all macOS-specific issues transparently.

### Using v2 Scripts

**Check Status (v2):**
```bash
~/.claude/scripts/check-strikes-v2.sh

# Output:
# CLAUDE CONSEQUENCE SYSTEM STATUS
# Strikes: 0 / 3
# Status: CLEAN ✅
```

**Add Strike (v2):**
```bash
# Syntax: add-strike-v2.sh VIOLATION_TYPE "description"
~/.claude/scripts/add-strike-v2.sh mister_bypass "Responded directly instead of using mm keyword"

# Automatically:
# 1. Strips extended attributes
# 2. Handles JSON parsing safely
# 3. Updates registry
# 4. Reports status
```

**Record Success (v2):**
```bash
~/.claude/scripts/record-success-v2.sh

# Automatically:
# 1. Increments successful task counter
# 2. Checks if reward threshold (3 tasks) met
# 3. Reduces strikes if threshold met
# 4. Reports updated status
```

### When to Use v2 Versions

Use v2 scripts when:
- Running on macOS Sequoia or later
- You encounter "Operation not permitted" errors
- Extended attributes cause issues
- Standard scripts time out or fail

The v2 scripts are fully backward compatible and handle all edge cases.

---

## Troubleshooting Checklist

```bash
# If installation fails, run this checklist:

# 1. Verify jq installed
[ -x "$(command -v jq)" ] && echo "jq: OK" || echo "jq: MISSING"

# 2. Verify directory structure
[ -d ~/.claude/scripts ] && echo "scripts dir: OK" || echo "scripts dir: MISSING"
[ -d ~/.claude/hooks ] && echo "hooks dir: OK" || echo "hooks dir: MISSING"

# 3. Verify files exist
[ -f ~/.claude/.violation-registry.json ] && echo "registry: OK" || echo "registry: MISSING"
[ -f ~/.claude/scripts/check-strikes.sh ] && echo "check-strikes: OK" || echo "check-strikes: MISSING"

# 4. Verify permissions
[ -x ~/.claude/scripts/check-strikes.sh ] && echo "permissions: OK" || echo "permissions: WRONG"

# 5. Verify no quarantine attributes
xattr ~/.claude/scripts/check-strikes.sh | grep -q "quarantine" && echo "quarantine: FOUND (remove with v2)" || echo "quarantine: OK"

# 6. Test functionality
~/.claude/scripts/check-strikes.sh > /dev/null 2>&1 && echo "functionality: OK" || echo "functionality: BROKEN"
```

If any check fails, follow the corresponding solution above.

---

## Next Steps

1. **Enable in Claude:** Add the rules from `rules/consequence-system.md` to your Claude configuration
2. **Verify with `check-strikes.sh`:** Run monthly to track compliance
3. **Report Issues:** For macOS-specific problems, include output from verification steps
4. **Use v2 Scripts:** If any issues arise, switch to v2 versions immediately

---

## Getting Help

If issues persist:

1. Run the troubleshooting checklist above
2. Try v2 workaround scripts
3. Check GitHub Issues with macOS tag
4. Include output from `ls -la ~/.claude/` in reports

**Version:** macOS Setup v2.0
**Compatible:** macOS 12.0+ (Monterey and later)
**Last Updated:** 2026-01-03
