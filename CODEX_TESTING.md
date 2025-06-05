# 🔬 ICE-WEBAPP Codex Universal Testing Environment

## 🎯 Purpose
This document outlines the **accurate simulation** of ChatGPT's Codex Universal environment for testing ICE-WEBAPP components in conditions that mirror the actual Codex sandbox restrictions.

## ⚠️ **Critical Differences from Standard Development**

### **Network Restrictions (Accurately Simulated)**
The Codex environment has significant network limitations that our container simulates:

- **Yarn Registry Blocked**: `repo.yarnpkg.com` returns HTTP 503 errors
- **Corepack Restrictions**: Package manager auto-installation fails
- **Limited Package Access**: Some npm packages may be unreachable
- **Proxy Configurations**: Network access is filtered/proxied

### **Environment Constraints**
Based on [OpenAI Community feedback](https://community.openai.com/t/codex-docker-in-docker-in-environment-setup/1272369):
- No Docker-in-Docker support
- Kernel-level restrictions on certain operations
- Pre-configured runtime environment (no version management)
- Sandboxed filesystem access

## 🏗️ **Container Setup**

### **Quick Start**
```bash
# Start the accurate Codex simulation
docker compose -f docker-compose.codex.yml up -d codex-mirror

# Test environment readiness
docker exec ice-webapp-codex-test bash -c "node --version && npm --version"

# Run setup script with restrictions
docker exec ice-webapp-codex-test bash -c "cd /workspace/ice-webapp && bash setup-codex.sh --test"
```

### **Environment Specifications**
- **Base**: Ubuntu 24.04 (matches Codex Universal)
- **Node.js**: v22.16.0 (pre-installed, no version switching)
- **npm**: 10.9.2 (configured with timeouts and restrictions)
- **pnpm**: Limited availability (simulates network restrictions)
- **Python**: 3.12.3 (pre-installed)
- **Build Tools**: Complete GCC toolchain

## 🚫 **Simulated Restrictions**

### **Network Simulation**
Our container accurately simulates Codex network limitations:

```bash
# These are blocked in /etc/hosts to simulate network restrictions
127.0.0.1 repo.yarnpkg.com
127.0.0.1 registry.yarnpkg.com  
127.0.0.1 yarnpkg.com
```

### **Package Manager Limitations**
```bash
# Corepack disabled (common failure in Codex)
corepack disable 2>/dev/null || echo 'corepack disabled (simulating Codex restrictions)'

# Environment variables simulating restrictions
COREPACK_ENABLE_STRICT=0
COREPACK_ENABLE_NETWORK=0
```

## 🧪 **Testing Scenarios**

### **1. Setup Script Resilience**
Test how the setup script handles network failures:
```bash
docker exec ice-webapp-codex-test bash -c "cd /workspace/ice-webapp && bash setup-codex.sh --test"
```

**Expected Behavior:**
- ✅ npm configuration succeeds with fallbacks
- ⚠️ pnpm installation may fail (gracefully handled)  
- ✅ Project structure creation works
- ⚠️ Corepack operations fail with helpful messages

### **2. Dependency Installation**
Test package installation under restrictions:
```bash
docker exec ice-webapp-codex-test bash -c "cd /workspace/ice-webapp && npm install --verbose"
```

**Expected Behavior:**
- ✅ npm packages install successfully
- ⚠️ Some packages may timeout/fail
- ✅ Fallback strategies activate
- ⚠️ Yarn/pnpm commands restricted

### **3. Development Server**
Test development server startup:
```bash
docker exec ice-webapp-codex-test bash -c "cd /workspace/ice-webapp && npm run dev"
```

## 📊 **Validation Metrics**

### **Environment Compliance**
- ✅ **Node.js Version**: Exactly v22.16.0 (no flexibility)
- ✅ **Package Manager**: npm primary, pnpm restricted
- ✅ **Network Policy**: HTTP 503 from yarn registries
- ✅ **Build Tools**: All development tools available
- ✅ **Python**: Version 3.12.3 available

### **Failure Patterns** 
Our simulation reproduces common Codex issues:
```
❌ HTTP 503 errors from repo.yarnpkg.com
❌ Corepack prepare commands fail
❌ Network timeout on package downloads
✅ Graceful fallbacks to npm
✅ Clear error messages explaining restrictions
```

## 🛠️ **Development Workflow**

### **Recommended Testing Flow**
1. **Start Container**: `docker compose -f docker-compose.codex.yml up -d`
2. **Verify Environment**: Check Node.js, npm availability
3. **Test Setup**: Run setup script with `--test` flag
4. **Install Dependencies**: Use npm (not yarn/pnpm)
5. **Run Application**: Test dev server startup
6. **Validate Build**: Ensure production build works

### **Container Management**
```bash
# Start testing environment
./docker-manage.sh start

# Access container shell
./docker-manage.sh shell

# Monitor container status
./docker-manage.sh status

# View setup logs
./docker-manage.sh logs
```

## 🔍 **Troubleshooting**

### **Common Issues & Solutions**

#### **Issue**: Corepack fails with HTTP 503
```
❌ Internal Error: Server answered with HTTP 503 when performing the request to https://repo.yarnpkg.com/tags
```
**✅ Solution**: This is **expected behavior** in Codex. The setup script handles this gracefully.

#### **Issue**: pnpm not available
```
❌ pnpm: command not found
```
**✅ Solution**: Use npm instead. This simulates actual Codex restrictions.

#### **Issue**: Package installation timeouts
```
❌ npm ERR! network timeout
```
**✅ Solution**: Retry with shorter timeouts or skip optional dependencies.

## 🎯 **Best Practices for Codex Compatibility**

### **1. Package Manager Strategy**
```bash
# ✅ Primary: Use npm (always available)
npm install

# ⚠️ Fallback: Check pnpm availability first
if command -v pnpm >/dev/null 2>&1; then
    pnpm install
else
    echo "Using npm fallback (Codex restriction)"
    npm install
fi
```

### **2. Network Resilience**
```bash
# ✅ Configure timeouts for restricted environments
npm config set fetch-retry-maxtimeout 60000
npm config set fetch-retries 3
npm config set network-timeout 60000
```

### **3. Error Handling**
```bash
# ✅ Always provide fallbacks
install_dependencies() {
    if npm install 2>/dev/null; then
        echo "Dependencies installed via npm"
    else
        echo "Installation failed - check network restrictions"
        return 1
    fi
}
```

## 📚 **References**

- [OpenAI Codex Docker Environment Discussion](https://community.openai.com/t/codex-docker-in-docker-in-environment-setup/1272369)
- [Docker Multi-Container Best Practices](https://docs.docker.com/get-started/docker-concepts/running-containers/multi-container-applications/)
- [Node.js Container Development Guide](https://docs.docker.com/guides/nodejs/develop/)

---

## 📋 **Quick Reference**

### **Container Commands**
```bash
# Start Codex simulation
docker compose -f docker-compose.codex.yml up -d

# Test environment
docker exec ice-webapp-codex-test node --version

# Run setup with restrictions
docker exec ice-webapp-codex-test bash -c "cd /workspace/ice-webapp && bash setup-codex.sh"

# Access container shell
docker exec -it ice-webapp-codex-test bash
```

### **Expected Environment**
- **Node.js**: v22.16.0 ✅
- **npm**: 10.9.2 ✅
- **pnpm**: Restricted ⚠️
- **Python**: 3.12.3 ✅
- **Network**: Limited/Proxied ⚠️
- **Build**: Fully supported ✅

**🎯 Result**: Accurate simulation of ChatGPT Codex Universal environment with realistic network restrictions and package manager limitations. 