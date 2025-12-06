# Consequence System Rules

## Violations Tracked

1. **mister_bypass**: User says "mm" but Claude responds directly
2. **mock_data**: Claude uses fake/synthetic data
3. **naming_violation**: MD file without proper naming

## Escalation

```
Strikes: 0  → Clean
Strikes: 1  → Warning logged
Strikes: 2  → Context compression forced
Strikes: 3  → Tool lockdown (10 min)
```

## Reward (NSR/PSR Balance)

- 3 successful tasks = -1 strike
- Auto-reset every 24h

## Research Basis

Based on ArXiv 2506.01347: "Training with only negative samples can be highly effective"

Key insight: NSR works by "suppressing incorrect generations and redistributing probability mass toward other plausible candidates"
