#!/usr/bin/env bash
# codacy-runtime.sh  – 2025-06-05  (provider fixed to "gh"; 404 tolerated)
# Enhanced for ICE-WEBAPP with multi-environment support

set -Eeuo pipefail
trap 'echo "[codacy-runtime] ❌ failed @ line $LINENO"; exit 1' ERR

# ── secrets (must be exported or set in Actions secrets) ────────────
if [[ -f "$PWD/tools/.codacy-tokens" ]]; then
  source "$PWD/tools/.codacy-tokens"
fi
: "${CODACY_ACCOUNT_TOKEN:?export CODACY_ACCOUNT_TOKEN}"
: "${CODACY_PROJECT_TOKEN:?export CODACY_PROJECT_TOKEN}"

# ── repo slug — fixed for DrJLabs/ice-webapp — lower-case ──────────
ORG="drjlabs"
REPO="ice-webapp"
PROVIDER="gh"                    # GitHub-cloud slug in Codacy API

# ── ensure CLI cached in ./tools ───────────────────────────────────
CLI_DIR="$PWD/tools"
CLI_BIN="$CLI_DIR/codacy"

if ! [[ -x $CLI_BIN ]]; then
  echo "[codacy-runtime] Downloading Codacy CLI …"
  mkdir -p "$CLI_DIR"
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' RETURN
  curl -fsSL "$(curl -fsSL https://api.github.com/repos/codacy/codacy-cli-v2/releases/latest \
      | grep -Po '"browser_download_url":\s*"\K.*linux_amd64.*\.tar\.gz(?=")' | head -n1)" \
      -o "$tmp/cli.tgz"
  tar -xzf "$tmp/cli.tgz" -C "$tmp"
  mv "$tmp"/codacy-cli* "$CLI_BIN" && chmod +x "$CLI_BIN"
  echo "[codacy-runtime] Codacy CLI installed."
else
  echo "[codacy-runtime] Codacy CLI present."
fi
export PATH="$CLI_DIR:$PATH"

# ── enforce local-analysis flag (non-fatal if 404) ─────────────────
echo "[codacy-runtime] Enforcing buildServerAnalysis flag …"
if ! curl -fsS -o /dev/null -w "%{http_code}" -X PATCH \
  "https://app.codacy.com/api/v3/organizations/${PROVIDER}/${ORG}/repositories/${REPO}/buildServerAnalysis" \
  -H "api-token: $CODACY_ACCOUNT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"enabled":true}' | grep -qE '^(200|204)$'; then
    echo "[codacy-runtime] ⚠️  PATCH returned non-200 (flag may already be set or repo slug differs). Continuing."
fi

echo "[codacy-runtime] ✔ Ready – $($CLI_BIN version | head -n1)" 