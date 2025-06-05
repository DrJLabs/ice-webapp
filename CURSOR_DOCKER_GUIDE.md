# 🧊 ICE-WEBAPP Docker Integration with Cursor IDE

## Quick Start with Docker Extensions

Your Cursor IDE is now enhanced with Docker extensions and dev containers! Here's how to leverage them for ICE-WEBAPP development.

## 🚀 Available Docker Tools

### 1. Docker Management Script
Interactive management tool with 11 commands:

```bash
./docker-manage.sh
```

**Available Commands:**
- 🚀 Start Codex Universal Container
- 🔧 Connect to Container (Interactive Shell)
- 📋 Show Container Status
- 📱 Run Setup Script in Container
- 🌐 Start Next.js Dev Server
- 📊 Show Container Logs
- 🧪 Run Test Suite
- 🛑 Stop Container
- 🗑️ Clean All Containers
- 📖 Open in Dev Container (Cursor IDE)
- 🔍 Container Resource Usage

### 2. Dev Container Configuration
Pre-configured for seamless Cursor IDE integration:

```json
{
  "name": "ICE-WEBAPP Codex Universal",
  "image": "ghcr.io/openai/codex-universal:latest",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {}
  }
}
```

## 🎯 Recommended Workflow

### Option A: Using Dev Containers (Recommended)

1. **Open in Dev Container:**
   ```
   Ctrl+Shift+P → "Dev Containers: Reopen in Container"
   ```

2. **Automatic Setup:**
   - Codex Universal image loads
   - Node.js 22 configured
   - Extensions installed automatically
   - Setup script runs

3. **Start Development:**
   ```bash
   npm run dev
   ```

### Option B: Using Docker Compose

1. **Start Container:**
   ```bash
   ./docker-manage.sh
   # Select option 1: Start Codex Universal Container
   ```

2. **Connect to Container:**
   ```bash
   # Select option 2: Connect to Container
   ```

3. **Run Setup:**
   ```bash
   # Select option 4: Run Setup Script
   ```

### Option C: Direct Docker Commands

```bash
# Quick start for testing
docker run -it --rm \
  -v "$(pwd):/workspace/ice-webapp" \
  -w /workspace/ice-webapp \
  -p 3000:3000 \
  ghcr.io/openai/codex-universal:latest \
  bash -c "source ~/.nvm/nvm.sh && bash"
```

## 🔧 Container Environment

The Codex Universal container includes:

- **Node.js 22.16.0** (managed by nvm)
- **npm 10.9.2** (latest)
- **pnpm 10.11.0** (fast package manager)
- **Python 3.12.3** (for tooling)
- **Bun 1.2.14** (alternative runtime)
- **Go 1.23.8** (systems programming)
- **Git** (version control)

## 📱 Cursor IDE Integration Features

### Extensions Pre-configured:
- TypeScript language support
- Tailwind CSS IntelliSense
- Prettier code formatter
- ESLint for code quality
- Docker extension
- GitHub Copilot integration

### IDE Settings:
```json
{
  "typescript.preferences.includePackageJsonAutoImports": "on",
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "terminal.integrated.defaultProfile.linux": "bash"
}
```

### Port Forwarding:
- **3000**: Next.js development server
- **3001**: Additional dev server
- **8080**: Alternative port

## 🐛 Troubleshooting

### Container Issues

**Problem: Container exits immediately**
```bash
# Solution: Use the management script
./docker-manage.sh
# Select option 1 to start with proper initialization
```

**Problem: Node.js not found**
```bash
# Solution: Source nvm in every shell session
source ~/.nvm/nvm.sh && nvm use 22
```

**Problem: Permission errors**
```bash
# Solution: Run as root (default in Codex Universal)
docker exec -u root ice-webapp-codex-test bash
```

### Dev Container Issues

**Problem: "Dev Containers" command not found**
1. Install "Dev Containers" extension in Cursor
2. Restart Cursor IDE
3. Try again: `Ctrl+Shift+P → Dev Containers: Reopen in Container`

**Problem: Container slow to start**
- Normal behavior - Codex Universal image is large
- Wait for "Environment ready" message
- Check progress in Docker extension panel

## 📊 Docker Extensions Usage

### With Docker Extension Panel:
1. View running containers
2. Inspect container details
3. View logs in real-time
4. Manage volumes and networks
5. Execute commands directly

### With Docker Compose Extension:
1. Start/stop multi-container setups
2. View service dependencies
3. Scale services
4. Monitor resource usage

## 🚀 Development Commands

### Inside Container:
```bash
# Install dependencies
pnpm install

# Start development server
npm run dev

# Type checking
npm run type-check

# Linting
npm run lint

# Build for production
npm run build

# Run tests
npm run test
```

### From Host (using management script):
```bash
./docker-manage.sh
# Select option 5: Start Next.js Dev Server
# Select option 7: Run Test Suite
```

## 📈 Performance Tips

1. **Use pnpm** for faster installs
2. **Enable Docker BuildKit** for faster builds
3. **Use volume caching** for node_modules
4. **Limit container resources** if needed

## 🔒 Security Considerations

- Container runs as root (Codex Universal default)
- Files are bind-mounted from host
- Network access enabled for package installation
- Use `.dockerignore` to exclude sensitive files

## 📝 Next Steps

1. **Start with dev containers** - best Cursor integration
2. **Use the management script** - comprehensive tooling
3. **Check Docker extension panel** - visual container management
4. **Customize dev container config** - tailor to your needs

---

*This setup mirrors the ChatGPT Codex environment for consistent development experience across all platforms.* 