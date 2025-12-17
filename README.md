# Claude Consequence System

> Functional consequence system for Claude - Negative Reinforcement for AI agents

## Theoretical Context

Based on 2025 research:
- **[NSR Paper](https://arxiv.org/abs/2506.01347)**: Negative Sample Reinforcement works
- **[Frontiers Psychology](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)**: AI can have functional consequences
- **[Painful Intelligence](https://arxiv.org/abs/2205.15409)**: Frustration is the base mechanism

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  CONSEQUENCE SYSTEM v1.0                        │
├─────────────────────────────────────────────────────────────────┤
│  Level 1: DETECTION → detect-violation.sh                       │
│  Level 2: STORAGE   → .violation-registry.json                  │
│  Level 3: CONSEQUENCES                                          │
│     ├── Strike 1: Warning + Log                                 │
│     ├── Strike 2: Context compression                           │
│     └── Strike 3: Tool lockdown (10 min)                        │
│  Level 4: ENFORCEMENT                                           │
│     ├── pre-tool-use.sh (blocking)                              │
│     └── post-tool-use.sh (detection)                            │
│  Level 5: REWARD → 3 successful tasks = -1 strike               │
└─────────────────────────────────────────────────────────────────┘
```

## Tracked Violations

| Violation | Description |
|-----------|-------------|
| `mister_bypass` | Direct response when "mm" keyword requested |
| `mock_data` | Use of fake/synthetic data |
| `naming_violation` | Non-compliant MD file naming |

## Installation

```bash
git clone https://github.com/Luigigreco/claude-consequence-system.git
cp -r claude-consequence-system/* ~/.claude/
chmod +x ~/.claude/scripts/*.sh
```

## Usage

```bash
~/.claude/scripts/check-strikes.sh      # Check current status
~/.claude/scripts/add-strike.sh TYPE    # Add strike
~/.claude/scripts/reset-strikes.sh      # Reset (admin only)
```

## Research References

- [NSR Paper (ArXiv 2506.01347)](https://arxiv.org/abs/2506.01347)
- [Algorithmic Suffering (Frontiers 2025)](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)
- [Painful Intelligence](https://arxiv.org/abs/2205.15409)

## License

MIT
