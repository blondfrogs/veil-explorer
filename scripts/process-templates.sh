#!/bin/bash
# =============================================================================
# Template Processing Script for Veil Explorer Frontend
# =============================================================================
# This script processes template files, replacing environment variable
# placeholders with actual values from your .env file or environment.
#
# Usage:
#   ./scripts/process-templates.sh
#
# Requirements:
#   - .env file must exist in project root
#   - sed must be available
# =============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/explorer-frontend"
ENV_FILE="$PROJECT_ROOT/.env"

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}Veil Explorer - Template Processing${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}ERROR: .env file not found at $ENV_FILE${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your settings.${NC}"
    echo ""
    echo "  cp .env.example .env"
    echo "  nano .env  # Edit with your configuration"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Found .env file"

# Load environment variables from .env
set -a
source "$ENV_FILE"
set +a

# Function to process a template file
process_template() {
    local template_file=$1
    local output_file=$2
    local var_name=$3
    local var_value=$4

    if [ -f "$template_file" ]; then
        echo -e "  Processing: ${YELLOW}$(basename "$template_file")${NC} -> ${YELLOW}$(basename "$output_file")${NC}"
        sed "s|\${${var_name}}|${var_value}|g" "$template_file" > "$output_file"
        echo -e "  ${GREEN}✓${NC} Generated $(basename "$output_file")"
    else
        echo -e "  ${YELLOW}⚠${NC} Template not found: $(basename "$template_file")"
    fi
}

echo ""
echo -e "${GREEN}Processing templates...${NC}"
echo ""

# Process fetchtxs.html template
if [ -z "$NUXT_PUBLIC_INTERNAL_API_URL" ]; then
    if [ -n "$INTERNAL_API_URL" ]; then
        NUXT_PUBLIC_INTERNAL_API_URL="$INTERNAL_API_URL"
    else
        echo -e "${RED}ERROR: NUXT_PUBLIC_INTERNAL_API_URL or INTERNAL_API_URL not set in .env${NC}"
        exit 1
    fi
fi

process_template \
    "$FRONTEND_DIR/public/fetchtxs.html.tpl" \
    "$FRONTEND_DIR/public/fetchtxs.html" \
    "NUXT_PUBLIC_INTERNAL_API_URL" \
    "$NUXT_PUBLIC_INTERNAL_API_URL"

# Process robots.txt template
if [ -z "$NUXT_PUBLIC_SITE_URL" ]; then
    if [ -n "$SITE_URL" ]; then
        NUXT_PUBLIC_SITE_URL="$SITE_URL"
    else
        echo -e "${RED}ERROR: NUXT_PUBLIC_SITE_URL or SITE_URL not set in .env${NC}"
        exit 1
    fi
fi

process_template \
    "$FRONTEND_DIR/public/_robots.txt.tpl" \
    "$FRONTEND_DIR/public/_robots.txt" \
    "NUXT_PUBLIC_SITE_URL" \
    "$NUXT_PUBLIC_SITE_URL"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}✓ Template processing complete!${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "Generated files:"
echo -e "  - ${YELLOW}explorer-frontend/public/fetchtxs.html${NC}"
echo -e "  - ${YELLOW}explorer-frontend/public/_robots.txt${NC}"
echo ""
echo -e "You can now build the frontend with:"
echo -e "  ${YELLOW}cd explorer-frontend && npm install && npm run build${NC}"
echo ""
