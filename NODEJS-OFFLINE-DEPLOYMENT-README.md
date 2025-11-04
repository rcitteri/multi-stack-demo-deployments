# Node.js Offline Deployment for Cloud Foundry

This directory contains two methods for deploying Node.js applications to Cloud Foundry environments that cannot access external npm registries during buildpack execution.

---

## 🎯 Recommended Method: npm-packages-offline-cache

**Use the official Cloud Foundry offline cache method** (documented at https://docs.cloudfoundry.org/buildpacks/node/index.html#vendoring)

### Quick Start

```bash
# Simple demo
cd simple-demo/nodejs-demo
./create-offline-cache.sh
cf push

# DB demo
cd db-demo/nodejs-demo
./create-offline-cache.sh
./create-db-service.sh postgres  # if needed
cf push
```

### How It Works

1. Create `npm-packages-offline-cache/` directory with packaged dependencies (.tgz files)
2. Upload cache + `.yarnrc` + `yarn.lock` to Cloud Foundry
3. Buildpack detects cache and runs Yarn in offline mode
4. No `node_modules/` upload required - cache provides dependencies

### Buildpack Output

```
-----> Detected npm-packages-offline-cache directory
-----> Running yarn in offline mode
```

### Files Created

- `npm-packages-offline-cache/` - Contains all dependencies as .tgz archives
- `.yarnrc` - Yarn offline configuration
- `yarn.lock` - Dependency lock file

**See**: `OFFLINE-CACHE-GUIDE.md` for complete documentation

---

## Alternative Method: node_modules Vendoring

**Fallback approach** - Upload `node_modules/` directory directly

### Quick Start

```bash
cd simple-demo/nodejs-demo  # or db-demo/nodejs-demo
./vendor-deps.sh
cf push
```

### How It Works

1. Run `npm install --production` locally
2. Include `node_modules/` in Cloud Foundry upload
3. Buildpack detects existing modules and skips `npm install`

### Buildpack Output

```
-----> Skipping npm install (node_modules present)
```

**See**: `VENDORING.md` (in each demo directory) for details

---

## Comparison

| Feature | npm-packages-offline-cache | node_modules Vendoring |
|---------|---------------------------|------------------------|
| **Official CF Method** | ✅ Yes | ❌ No |
| **Documentation** | ✅ Official CF docs | ❌ Not documented |
| **Upload Size** | ✅ Smaller (.tgz compressed) | ❌ Larger (full modules) |
| **Buildpack Support** | ✅ Explicit offline mode | ⚠️ Implicit detection |
| **Setup Complexity** | Requires Yarn | Uses npm only |
| **Reproducibility** | ✅ yarn.lock | ⚠️ package-lock.json |
| **Best Practice** | ✅ Recommended | ⚠️ Workaround |

---

## Which Method to Use?

### Use npm-packages-offline-cache (Recommended) When:

- ✅ You want the official, documented approach
- ✅ You need smaller upload sizes
- ✅ You want explicit offline mode in buildpack
- ✅ You're okay using Yarn for cache creation
- ✅ You want maximum reproducibility

### Use node_modules Vendoring When:

- ⚠️ You cannot install or use Yarn
- ⚠️ You prefer npm-only workflow
- ⚠️ You need quick workaround without Yarn

**Recommendation**: Use `npm-packages-offline-cache` (the official method)

---

## Scripts Available

### Offline Cache Method (Recommended)

```bash
./create-offline-cache.sh   # Creates npm-packages-offline-cache directory
```

### Vendoring Method (Alternative)

```bash
./vendor-deps.sh            # Creates production node_modules
```

### Deployment Scripts (Use Either Method)

All deployment scripts automatically prepare dependencies:

```bash
./deploy-default.sh         # Deploys default version
./deploy-blue.sh           # Deploys blue version (1.0.0)
./deploy-green.sh          # Deploys green version (2.0.0)
```

**Current Configuration**: Deployment scripts use `create-offline-cache.sh` (official method)

---

## File Structure

### With npm-packages-offline-cache (Recommended)

```
nodejs-demo/
├── npm-packages-offline-cache/   # Offline package cache ✅
│   ├── express-4.18.2.tgz
│   ├── dotenv-16.3.1.tgz
│   └── ... (all dependencies)
├── .yarnrc                        # Yarn offline config ✅
├── yarn.lock                      # Lock file ✅
├── node_modules/                  # Local only (not uploaded)
├── package.json
└── manifest.yml
```

### With node_modules Vendoring (Alternative)

```
nodejs-demo/
├── node_modules/                  # Vendored dependencies ✅
│   ├── express/
│   ├── dotenv/
│   └── ... (all packages)
├── package.json
└── manifest.yml
```

---

## Configuration Files

### .gitignore (both methods)

```bash
# Keep out of version control
node_modules/
npm-packages-offline-cache/
.yarnrc
yarn.lock
```

### .cfignore (npm-packages-offline-cache)

```bash
# INCLUDE for Cloud Foundry upload:
# - npm-packages-offline-cache/
# - .yarnrc
# - yarn.lock

# EXCLUDE from upload:
node_modules/     # Not needed - cache provides deps
.git/
*.log
```

### .cfignore (node_modules vendoring)

```bash
# INCLUDE for Cloud Foundry upload:
# - node_modules/

# EXCLUDE from upload:
.git/
*.log
```

---

## Environment Variables

Both methods use the same manifest.yml configuration:

```yaml
env:
  NODE_ENV: production
  NPM_CONFIG_PRODUCTION: true
  OPTIMIZE_MEMORY: true
```

---

## Verification

### Verify Offline Cache

```bash
ls npm-packages-offline-cache/    # Should show .tgz files
ls .yarnrc                         # Should exist
ls yarn.lock                       # Should exist
du -sh npm-packages-offline-cache/ # Check size
```

### Verify node_modules Vendoring

```bash
ls node_modules/                   # Should show packages
npm list --production --depth=0    # List installed packages
du -sh node_modules/               # Check size
```

---

## Common Issues

### Issue: Yarn not installed

**Solution for offline cache**:
```bash
npm install -g yarn
./create-offline-cache.sh
```

**Alternative**: Use `vendor-deps.sh` instead (npm-only)

### Issue: Cache not uploaded to CF

**Check .cfignore**:
```bash
grep npm-packages-offline-cache .cfignore
# Should return NOTHING (cache should be included)
```

### Issue: node_modules not uploaded to CF

**Check .cfignore**:
```bash
grep "^node_modules/" .cfignore
# Should return NOTHING (modules should be included)
```

---

## Documentation

### Main Guides

- **OFFLINE-CACHE-GUIDE.md** - Complete guide for npm-packages-offline-cache (official method)
- **VENDORING-QUICKSTART.md** - Quick reference for both methods
- **simple-demo/nodejs-demo/VENDORING.md** - Detailed vendoring guide for simple demo
- **db-demo/nodejs-demo/VENDORING.md** - Detailed vendoring guide for db demo

### Official Resources

- [Cloud Foundry Node.js Buildpack - Vendoring](https://docs.cloudfoundry.org/buildpacks/node/index.html#vendoring)
- [Yarn Offline Mirror](https://classic.yarnpkg.com/blog/2016/11/24/offline-mirror/)
- [Node.js Buildpack GitHub](https://github.com/cloudfoundry/nodejs-buildpack)

---

## Migration Guide

### From node_modules to npm-packages-offline-cache

```bash
# 1. Clean vendored node_modules
rm -rf node_modules package-lock.json

# 2. Create offline cache
./create-offline-cache.sh

# 3. Verify cache
ls npm-packages-offline-cache/

# 4. Deploy
cf push
```

### From npm-packages-offline-cache to node_modules

```bash
# 1. Clean offline cache
rm -rf npm-packages-offline-cache .yarnrc yarn.lock

# 2. Create vendored node_modules
./vendor-deps.sh

# 3. Verify modules
ls node_modules/

# 4. Deploy
cf push
```

---

## Quick Reference

### Official Method (Recommended)

```bash
# Create cache
./create-offline-cache.sh

# Deploy
cf push

# What gets uploaded:
# ✓ npm-packages-offline-cache/
# ✓ .yarnrc
# ✓ yarn.lock
# ✗ node_modules/ (excluded)
```

### Alternative Method

```bash
# Create vendored deps
./vendor-deps.sh

# Deploy
cf push

# What gets uploaded:
# ✓ node_modules/
# ✗ npm-packages-offline-cache/ (not created)
```

---

## Testing Offline Mode Locally

### Test Yarn Offline Mode

```bash
# Create cache
./create-offline-cache.sh

# Clear node_modules
rm -rf node_modules

# Install from cache (offline)
yarn install --offline --production

# Should work without internet!
```

### Test npm Vendoring

```bash
# Create vendored modules
./vendor-deps.sh

# Test app
npm start

# Should work without npm install
```

---

## Support

- **Issues**: Check troubleshooting sections in respective documentation
- **Cloud Foundry Docs**: https://docs.cloudfoundry.org/buildpacks/node/
- **Buildpack Versions**: `cf buildpacks` to check installed buildpacks

---

## Summary

**For production air-gapped Cloud Foundry deployments**, use:

```bash
./create-offline-cache.sh  # Creates npm-packages-offline-cache
cf push                     # Buildpack detects and uses offline mode
```

This is the **official, documented, and recommended** approach. ✅

---

**Ready to deploy?**

```bash
# Navigate to your demo
cd simple-demo/nodejs-demo  # or db-demo/nodejs-demo

# Create offline cache (official method)
./create-offline-cache.sh

# Deploy to Cloud Foundry
cf push

# Success! 🚀
```
