#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODACY_DIR="${ROOT_DIR}/.codacy"

echo "🧊 Setting up Codacy CLI for ICE-WEBAPP..."

# Create .codacy directory if it doesn't exist
mkdir -p "${CODACY_DIR}"
mkdir -p "${CODACY_DIR}/tools-configs"
mkdir -p "${CODACY_DIR}/logs"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
  echo "❌ curl is required but not installed. Please install curl and try again."
  exit 1
fi

# Download Codacy CLI
echo "📥 Downloading Codacy CLI..."
curl -sSL https://raw.githubusercontent.com/codacy/codacy-cli-v2/main/codacy-cli.sh -o "${SCRIPT_DIR}/codacy-cli.sh"
chmod +x "${SCRIPT_DIR}/codacy-cli.sh"

# Create a symlink to make it available as 'codacy-cli'
echo "🔗 Creating symlink for codacy-cli..."
if [ ! -f "${ROOT_DIR}/node_modules/.bin/codacy-cli" ]; then
  mkdir -p "${ROOT_DIR}/node_modules/.bin"
  ln -sf "${SCRIPT_DIR}/codacy-cli.sh" "${ROOT_DIR}/node_modules/.bin/codacy-cli"
fi

# Create .gitignore file if it doesn't exist
if [ ! -f "${CODACY_DIR}/.gitignore" ]; then
  echo "📝 Creating .gitignore file for .codacy directory..."
  cat > "${CODACY_DIR}/.gitignore" << EOF
logs/
tools/
EOF
fi

# Configure Codacy CLI
if [ ! -f "${CODACY_DIR}/codacy.yaml" ] || [ ! -s "${CODACY_DIR}/codacy.yaml" ]; then
  echo "⚙️ Creating default Codacy configuration..."
  cat > "${CODACY_DIR}/codacy.yaml" << EOF
runtimes:
    - dart@3.7.2
    - java@17.0.10
    - node@22.2.0
    - python@3.11.11
tools:
    - dartanalyzer@3.7.2
    - eslint@8.57.0
    - lizard@1.17.19
    - pmd@6.55.0
    - pylint@3.3.6
    - semgrep@1.78.0
    - trivy@0.59.1
EOF
fi

# Configure CLI mode
echo "⚙️ Setting CLI mode to local..."
cat > "${CODACY_DIR}/cli-config.yaml" << EOF
mode: local
EOF

# Install Codacy CLI tools
echo "🔧 Installing Codacy CLI tools..."
"${SCRIPT_DIR}/codacy-cli.sh" install

echo "✅ Codacy CLI setup complete!"
echo "You can now run analyses with: ${SCRIPT_DIR}/codacy-cli.sh analyze" 