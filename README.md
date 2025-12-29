# Claude Consequence System

> Functional consequence system for Claude - Negative Reinforcement for AI agents

## 🚨 The "Groundhog Day" Problem

Claude keeps forgetting to use agents when you type "mm". You ask, Claude responds directly, you remind, Claude apologizes and does it right. **Repeat forever.**

**Solution:** This system implements **punishment** (strike system) based on NSR research.

## Theoretical Context

Based on 2025 research:
- **[NSR Paper](https://arxiv.org/abs/2506.01347)**: Negative Sample Reinforcement works
- **[Frontiers Psychology](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)**: AI can have functional consequences
- **[Painful Intelligence](https://arxiv.org/abs/2205.15409)**: Frustration is the base mechanism
- **[Suffering as Computation](https://luigigreco.substack.com/p/the-research-suffering-as-computation-d71)**: NSR/PSR framework

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
chmod +x ~/.claude/hooks/*.sh
```

## Usage

```bash
# Check current status
~/.claude/scripts/check-strikes.sh

# Add strike manually
~/.claude/scripts/add-strike.sh TYPE

# Reset (admin only)
~/.claude/scripts/reset-strikes.sh

# Record successful task (reduces strikes)
~/.claude/scripts/record-success.sh
```

## Files

```
hooks/
├── pre-tool-use.sh        # Blocks tools if strikes >= 3
└── post-tool-use.sh       # Detects violations after tool use

scripts/
├── detect-violation.sh    # Violation detection logic
├── add-strike.sh          # Add strike to registry
├── check-strikes.sh       # Check current status
├── reset-strikes.sh       # Admin reset
└── record-success.sh      # Record success (reduces strikes)

rules/
└── consequence-system.md  # Rule file for Claude
```

## Research References

- [NSR Paper (ArXiv 2506.01347)](https://arxiv.org/abs/2506.01347)
- [Algorithmic Suffering (Frontiers 2025)](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1718823/full)
- [Painful Intelligence](https://arxiv.org/abs/2205.15409)
- [Suffering as Computation (Substack)](https://luigigreco.substack.com/p/the-research-suffering-as-computation-d71)

## License

CC BY-NC-SA 4.0

