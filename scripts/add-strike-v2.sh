#!/bin/bash
# Add Strike v2 - Consequence System Integration
# Usage: add-strike-v2.sh <type> <description>
#
# Uses /tmp workaround for macOS permission issues
# Compatible with Claude Write tool workflow
#
# Example:
#   add-strike-v2.sh gitonly_bypass "Write tool used in git-only mode"
#   add-strike-v2.sh mock_data "Generated fake financial data in analysis"
#   add-strike-v2.sh naming_violation "MD file created without naming convention"

set -euo pipefail

# Configuration
VIOLATION_TYPE="${1:-unknown}"
DESCRIPTION="${2:-No description provided}"
REGISTRY_PATH="$HOME/.claude/.violation-registry-v2.json"
TEMP_REGISTRY="/tmp/claude/claude-registry-update-$(date +%s).json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Validate inputs
if [ -z "$VIOLATION_TYPE" ] || [ "$VIOLATION_TYPE" = "unknown" ]; then
    echo -e "${RED}❌ ERROR: Violation type required${NC}"
    echo "Usage: add-strike-v2.sh <type> <description>"
    echo ""
    echo "Valid types:"
    echo "  - mister_bypass"
    echo "  - mock_data"
    echo "  - naming_violation"
    echo "  - gitonly_bypass"
    echo "  - local_write_default"
    exit 1
fi

# Check if registry exists
if [ ! -f "$REGISTRY_PATH" ]; then
    echo -e "${RED}❌ ERROR: Registry not found at $REGISTRY_PATH${NC}"
    exit 1
fi

# Read current registry
if ! CURRENT_REGISTRY=$(cat "$REGISTRY_PATH" 2>/dev/null); then
    echo -e "${RED}❌ ERROR: Cannot read registry${NC}"
    exit 1
fi

# Extract current values
CURRENT_STRIKES=$(echo "$CURRENT_REGISTRY" | jq -r '.strikes // 0')
CURRENT_SUCCESSFUL=$(echo "$CURRENT_REGISTRY" | jq -r '.successful_tasks // 0')
NEW_STRIKES=$((CURRENT_STRIKES + 1))

# Create updated registry using jq
UPDATED_REGISTRY=$(echo "$CURRENT_REGISTRY" | jq \
  --arg type "$VIOLATION_TYPE" \
  --arg desc "$DESCRIPTION" \
  --arg ts "$TIMESTAMP" \
  --argjson newstrikes "$NEW_STRIKES" \
  '.strikes = $newstrikes |
   .successful_tasks = 0 |
   .violations += [{
     "type": $type,
     "description": $desc,
     "timestamp": $ts
   }] |
   .last_violation_timestamp = $ts' 2>/dev/null)

if [ -z "$UPDATED_REGISTRY" ]; then
    echo -e "${RED}❌ ERROR: Failed to create updated registry${NC}"
    exit 1
fi

# Write to temp file first (avoids permission issues)
if ! echo "$UPDATED_REGISTRY" > "$TEMP_REGISTRY"; then
    echo -e "${RED}❌ ERROR: Cannot write to temp file $TEMP_REGISTRY${NC}"
    exit 1
fi

# Display consequence warning
echo ""
echo -e "${RED}═══════════════════════════════════════════${NC}"
echo -e "${RED}    ⚠️  VIOLATION RECORDED${NC}"
echo -e "${RED}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Violation Type:${NC}  $VIOLATION_TYPE"
echo -e "${YELLOW}Description:${NC}     $DESCRIPTION"
echo -e "${YELLOW}Timestamp:${NC}       $TIMESTAMP"
echo ""
echo -e "${BLUE}Strike Counter:${NC}   ${RED}$NEW_STRIKES${NC} / 3"
echo ""

# Display consequence based on strike level
case $NEW_STRIKES in
    1)
        echo -e "${YELLOW}🔔 CONSEQUENCE: WARNING LOGGED${NC}"
        echo "   The violation has been recorded in the system."
        echo "   Next violation will trigger context compression."
        ;;
    2)
        echo -e "${YELLOW}⚠️  CONSEQUENCE: CONTEXT COMPRESSION ACTIVE${NC}"
        echo "   - Responses will be more concise"
        echo "   - Context usage will be reduced"
        echo "   - Warning displayed on every tool use"
        echo "   One more violation triggers tool lockdown."
        ;;
    3)
        echo -e "${RED}⛔ CONSEQUENCE: TOOL LOCKDOWN ACTIVATED${NC}"
        echo "   - Task tool BLOCKED for 10 minutes"
        echo "   - Agent orchestration restricted"
        echo "   - Requires admin reset to resume"
        echo ""
        echo "   Use: reset-strikes.sh (admin only)"
        ;;
    *)
        echo -e "${RED}🚨 CRITICAL: Strike limit exceeded (${NEW_STRIKES}/3)${NC}"
        ;;
esac

echo ""
echo -e "${RED}═══════════════════════════════════════════${NC}"
echo ""

# Show temp file location for manual update
echo -e "${BLUE}📝 Next Step:${NC}"
echo "   Updated registry prepared at: $TEMP_REGISTRY"
echo ""
echo "   To apply, use Claude Write tool:"
echo "   Path: $REGISTRY_PATH"
echo "   Content: (copy from $TEMP_REGISTRY)"
echo ""

# Try to show the JSON for reference (first 30 lines)
echo -e "${BLUE}📊 Updated Registry Preview:${NC}"
echo "$UPDATED_REGISTRY" | jq '.' | head -30
echo ""

# Output path for scripting
echo "$TEMP_REGISTRY"

exit 0
