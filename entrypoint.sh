#!/bin/bash
set -e

echo "=========================================="
echo "  ICE-WEBAPP Codex Environment (Replica)  "
echo "=========================================="
echo
echo "Verifying pre-installed tools..."
echo "  - Node.js: $(node --version)"
echo "  - npm:     $(npm --version)"
echo "  - pnpm:    $(pnpm --version)"
echo "  - Python:  $(python3 --version)"
echo
echo "Environment is ready."
echo "Dropping into a bash shell..."
echo

# Execute the command passed to the container
exec "$@" 