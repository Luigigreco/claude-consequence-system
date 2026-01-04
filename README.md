# Claude Consequence System

> Sistema di conseguenze funzionali per Claude - Negative Reinforcement per AI agents

## 🎉 What's New in V2

**macOS Fix:** V2 solves permission errors on macOS systems
- New `.violation-registry-v2.json` format (no extended attributes)
- `add-strike-v2.sh` workaround script for write permissions
- Auto-fallback in all scripts (v2 → v1)
- Backward compatible with v1 installations

**See:** [MACOS-SETUP.md](MACOS-SETUP.md) for detailed macOS installation

---

## Contesto Teorico

Basato su ricerca 2025:
- **[NSR Paper](https://arxiv.org/abs/2506.01347)**: Negative Sample Reinforcement funziona
- **[Frontiers Psychology](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)**: L'AI può avere conseguenze funzionali
- **[Painful Intelligence](https://arxiv.org/abs/2205.15409)**: La frustrazione è il meccanismo base

## Architettura

```
┌─────────────────────────────────────────────────────────────────┐
│                  CONSEQUENCE SYSTEM v2.0                        │
├─────────────────────────────────────────────────────────────────┤
│  Level 1: DETECTION → detect-violation.sh                       │
│  Level 2: STORAGE   → .violation-registry-v2.json (NEW)         │
│  Level 3: CONSEQUENCES                                          │
│     ├── Strike 1: Warning + Log                                 │
│     ├── Strike 2: Context compression                           │
│     └── Strike 3: Tool lockdown (10 min)                        │
│  Level 4: ENFORCEMENT                                           │
│     ├── pre-tool-use.sh (blocking)                              │
│     └── post-tool-use.sh (detection)                            │
│  Level 5: REWARD → 3 successful tasks = -1 strike               │
│  Level 6: MACOS FIX → add-strike-v2.sh workaround (NEW)         │
└─────────────────────────────────────────────────────────────────┘
```

## Violazioni Tracciate

| Violazione | Descrizione |
|------------|-------------|
| `mister_bypass` | Risposta diretta quando richiesto `mm` |
| `mock_data` | Uso di dati finti/sintetici |
| `naming_violation` | File MD non conforme |

## Installazione

```bash
git clone https://github.com/Luigigreco/claude-consequence-system.git
cp -r claude-consequence-system/* ~/.claude/
chmod +x ~/.claude/scripts/*.sh
```

## Usage

```bash
~/.claude/scripts/check-strikes.sh      # Check status
~/.claude/scripts/add-strike.sh TYPE    # Add strike
~/.claude/scripts/reset-strikes.sh      # Reset (admin)
```

## Research References

- [NSR Paper (ArXiv 2506.01347)](https://arxiv.org/abs/2506.01347)
- [Algorithmic Suffering (Frontiers 2025)](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)
- [Painful Intelligence](https://arxiv.org/abs/2205.15409)

---

## For Contributors

### Contributing to this Repository

If you want to contribute improvements or fixes to this project:

#### Method 1: GitHub Web Interface (Recommended for Small Changes)
1. Fork the repository
2. Make changes via GitHub web editor
3. Create Pull Request

#### Method 2: Local Development + gh CLI (For Larger Changes)

**Prerequisites:**
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login
```

**Workflow for Public Repository:**
```bash
# 1. Clone to temp directory (avoid macOS permission issues)
gh repo clone Luigigreco/claude-consequence-system /tmp/claude/repo-temp
cd /tmp/claude/repo-temp

# 2. Make your changes
# Edit files as needed

# 3. For each modified file, upload via gh API
FILE="path/to/modified/file"
SHA=$(gh api repos/Luigigreco/claude-consequence-system/contents/$FILE --jq '.sha' 2>/dev/null || echo "")

if [ -n "$SHA" ]; then
  # Update existing file
  gh api repos/Luigigreco/claude-consequence-system/contents/$FILE \
    --method PUT \
    --field message="feat: Your change description" \
    --field content="$(base64 -i $FILE)" \
    --field sha="$SHA" \
    --field branch="main"
else
  # Create new file
  gh api repos/Luigigreco/claude-consequence-system/contents/$FILE \
    --method PUT \
    --field message="feat: Add $FILE" \
    --field content="$(base64 -i $FILE)" \
    --field branch="main"
fi
```

**Why this method?**
- Public repositories require strong authentication
- Git push SSH requires SSH keys (may not be configured)
- gh API uses token authentication (simpler)
- Works around macOS permission issues

#### Method 3: Pull Request (Recommended for External Contributors)
```bash
# 1. Fork repository via GitHub web
# 2. Clone YOUR fork
gh repo clone YOUR_USERNAME/claude-consequence-system

# 3. Make changes and commit
git add .
git commit -m "feat: Your improvement"

# 4. Push to YOUR fork (SSH works on your own fork)
git push origin main

# 5. Create PR via gh CLI
gh pr create --title "Your improvement" --body "Description"
```

### Development Notes

- **macOS Users:** Use `/tmp/claude/` for temp files, not `/tmp`
- **Testing:** Run `bash scripts/add-strike-v2.sh test "Test message"` to verify
- **Validation:** Ensure `.violation-registry-v2.json` contains no private data
- **Documentation:** Update relevant .md files when changing functionality

---

## License

MIT
