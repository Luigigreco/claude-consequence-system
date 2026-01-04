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

## License

MIT
