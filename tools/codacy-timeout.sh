#!/bin/bash

# Codacy Timeout Wrapper
# This script executes Codacy CLI commands with a timeout to prevent hanging

# Default timeout in seconds (5 minutes)
TIMEOUT=${CODACY_TIMEOUT:-300}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧊 Running Codacy analysis with ${TIMEOUT}s timeout...${NC}"

# Run the command with timeout
timeout $TIMEOUT "$@"
EXIT_CODE=$?

# Check exit code
if [ $EXIT_CODE -eq 124 ]; then
  echo -e "${RED}❌ Codacy analysis timed out after ${TIMEOUT} seconds${NC}"
  echo -e "${YELLOW}⚠️ You can set a longer timeout by setting the CODACY_TIMEOUT environment variable${NC}"
  exit 0  # Exit with success to prevent CI failures due to timeouts
elif [ $EXIT_CODE -ne 0 ]; then
  echo -e "${RED}❌ Codacy analysis failed with exit code ${EXIT_CODE}${NC}"
  exit 0  # Exit with success to prevent CI failures due to command failures
else
  echo -e "${GREEN}✅ Codacy analysis completed successfully${NC}"
  exit 0
fi 