#!/usr/bin/env bash
set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
exec "$HERE/bin/codacy-cli" "$@"
