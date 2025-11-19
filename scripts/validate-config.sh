#!/bin/bash
# =============================================================================
# Veil Explorer Configuration Validation Script
# =============================================================================
# This script validates that all required environment variables are set
# before starting the application.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Required environment variables
REQUIRED_VARS=(
  "SITE_URL"
  "FRONTEND_URL"
  "BACKEND_API_URL"
  "INTERNAL_API_URL"
  "VEIL_NODE_URL"
  "VEIL_RPC_USER"
  "VEIL_RPC_PASSWORD"
  "POSTGRES_USER"
  "POSTGRES_PASSWORD"
  "POSTGRES_HOST"
  "POSTGRES_PORT"
  "REDIS_HOST"
  "REDIS_PORT"
)

# Optional but recommended variables
RECOMMENDED_VARS=(
  "VEIL_PROJECT_URL"
  "VEIL_STATS_URL"
  "VEIL_TOOLS_URL"
  "GITHUB_REPO_URL"
)

echo "===================================================================="
echo "Veil Explorer Configuration Validation"
echo "===================================================================="
echo ""

# Check for .env file
if [ ! -f .env ]; then
  echo -e "${RED}ERROR: .env file not found!${NC}"
  echo "Please copy .env.example to .env and configure it for your deployment."
  exit 1
fi

# Load .env file
export $(cat .env | grep -v '^#' | xargs)

# Track validation status
ERRORS=0
WARNINGS=0

# Validate required variables
echo "Checking required variables..."
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo -e "${RED}✗ ERROR: Required variable not set: $var${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}✓${NC} $var: ${!var}"
  fi
done

echo ""
echo "Checking recommended variables..."
for var in "${RECOMMENDED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo -e "${YELLOW}⚠ WARNING: Recommended variable not set: $var (will use default)${NC}"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${GREEN}✓${NC} $var: ${!var}"
  fi
done

echo ""
echo "===================================================================="

# Summary
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓ Configuration validation passed!${NC}"
  echo "All required and recommended variables are set."
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠ Configuration validation passed with warnings${NC}"
  echo "Required variables are set, but $WARNINGS recommended variable(s) missing."
  echo "The application will use default values for missing variables."
  exit 0
else
  echo -e "${RED}✗ Configuration validation FAILED${NC}"
  echo "Found $ERRORS error(s) and $WARNINGS warning(s)."
  echo "Please fix the errors before starting the application."
  exit 1
fi
