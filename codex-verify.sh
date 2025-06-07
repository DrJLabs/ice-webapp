#!/usr/bin/env bash
set -euo pipefail
python3 -V; node -v; go version; rustc --version
curl -s https://api.openai.com/ip | head -n1 && echo "Outbound net OK" 