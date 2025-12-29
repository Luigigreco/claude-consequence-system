#!/bin/bash
# =============================================================================
# USER PROMPT SUBMIT HOOK - PRE-EMPTIVE INTERCEPTION
# =============================================================================
# This hook intercepts user prompts BEFORE Claude processes them.
# It's the ONLY way to prevent "mm bypass" - catching it before response.
#
# Claude Code Hook Type: user-prompt-submit
# Trigger: Every user message submission
# Purpose: Force correct behavior BEFORE errors happen
# =============================================================================

USER_PROMPT="$1"

# =============================================================================
# RULE 1: MM MODE DETECTION (Critical)
# =============================================================================
# Pattern: "mm" at start of message, or "mm " followed by task
# Examples: "mm", "mm analizza", "mm check this project"

if echo "$USER_PROMPT" | grep -qiE "^\s*mm\b|^mm$"; then
    cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║   🤖 MM MODE INTERCEPTED - MANDATORY AGENT ORCHESTRATION                  ║
║                                                                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║   IRON RULES (INVIOLABLE):                                                ║
║                                                                           ║
║   1. You MUST use Task tool to launch specialized agents                  ║
║   2. Direct response is PROHIBITED - delegation is MANDATORY              ║
║   3. If you respond directly, you are VIOLATING the protocol              ║
║                                                                           ║
║   ❌ BLOCKED BEHAVIORS:                                                   ║
║      • Responding with your own analysis                                  ║
║      • Using Read/Grep/Glob/Write/Edit directly                           ║
║      • Saying "I'll analyze..." without Task tool                         ║
║      • Any response that doesn't start with Task tool call                ║
║                                                                           ║
║   ✅ REQUIRED BEHAVIOR:                                                   ║
║      • Immediately call Task tool with appropriate subagent_type          ║
║      • Launch 2-4 specialized agents in parallel                          ║
║      • Aggregate results from agents                                      ║
║                                                                           ║
║   CONSEQUENCE: Violation triggers strike → 3 strikes = tool lockdown      ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
fi

# =============================================================================
# RULE 2: MQC / MISTER CHECK DETECTION
# =============================================================================
if echo "$USER_PROMPT" | grep -qiE "^\s*mqc\b|mister\s+check"; then
    cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════════╗
║   🔍 MQC MODE - MISTER QUALITY CHECK                                      ║
╠═══════════════════════════════════════════════════════════════════════════╣
║   Validate: Agent usage, parallel execution, context-awareness            ║
║   Report: Score 0-100, recommendations                                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
fi

# =============================================================================
# RULE 3: GENIO / ULTRATHINK DETECTION
# =============================================================================
if echo "$USER_PROMPT" | grep -qiE "^\s*genio\b"; then
    cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════════╗
║   🧠 GENIO MODE - ULTRATHINK ACTIVATED                                    ║
╠═══════════════════════════════════════════════════════════════════════════╣
║   Extended thinking enabled. Deep analysis mode.                          ║
║   Take your time. Quality over speed.                                     ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
fi

exit 0
