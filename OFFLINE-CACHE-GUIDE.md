# Official Cloud Foundry Offline Cache Guide

## The Official Method: npm-packages-offline-cache

This guide explains the **official Cloud Foundry approach** for deploying Node.js applications in air-gapped or restricted environments that cannot access external npm registries during buildpack execution.

**Official Documentation**: https://docs.cloudfoundry.org/buildpacks/node/index.html#vendoring

---

## Quick Start

### Simple Demo

```bash
cd simple-demo/nodejs-demo

# Create offline cache
./create-offline-cache.sh

# Deploy to Cloud Foundry
cf push -f manifest.yml
```

### DB Demo

```bash
cd db-demo/nodejs-demo

# Create offline cache
./create-offline-cache.sh

# Create database service (if needed)
./create-db-service.sh postgres

# Deploy to Cloud Foundry
cf push -f manifest.yml
```

---

## How It Works

### 1. The Official Cloud Foundry Offline Method

Cloud Foundry's Node.js buildpack specifically looks for `npm-packages-offline-cache` directory:

```
my-app/
├── npm-packages-offline-cache/   ← Buildpack detects this!
│   ├── express-4.18.2.tgz
│   ├── dotenv-16.3.1.tgz
│   └── ... (all dependencies as .tgz files)
├── .yarnrc                        ← Yarn offline configuration
├── yarn.lock                      ← Dependency lock file
├── package.json
└── manifest.yml
```

**From CF Documentation**:
> "The buildpack looks for an npm-packages-offline-cache directory at the top level of the app directory. If this directory exists, the buildpack runs Yarn in offline mode. Otherwise, it runs Yarn normally, which may require an Internet connection."

### 2. Buildpack Detection

When you `cf push` with the offline cache:

```
-----> Node.js Buildpack version 1.x.x
-----> Installing binaries
       engines.node (package.json): >=18.0.0
-----> Installing node 18.x.x
-----> Detected npm-packages-offline-cache directory  ← KEY!
-----> Running yarn in offline mode                    ← KEY!
-----> Checking startup method
-----> Finalizing build
```

### 3. No node_modules Required

**Important**: You do NOT need to upload `node_modules/` when using the offline cache!

From CF documentation:
> "You do not have to provide a node_modules directory when running Yarn in offline mode, as the offline cache provides the dependencies."

---

## Creating the Offline Cache

### Method 1: Using the Script (Recommended)

```bash
# Automated - handles everything for you
./create-offline-cache.sh
```

This script:
1. Installs Yarn (if not present)
2. Configures Yarn for offline mirror
3. Creates `npm-packages-offline-cache/` directory
4. Populates it with .tgz package archives
5. Creates `.yarnrc` configuration
6. Creates `yarn.lock` for reproducibility

### Method 2: Manual Setup

```bash
# Step 1: Configure Yarn offline mirror
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
yarn config set yarn-offline-mirror-pruning true

# Step 2: Copy Yarn config to project
cp ~/.yarnrc .

# Step 3: Clean and install
rm -rf node_modules yarn.lock
yarn install --production

# Step 4: Verify cache was created
ls npm-packages-offline-cache/
```

---

## File Structure After Cache Creation

```
nodejs-demo/
├── npm-packages-offline-cache/         ← All dependencies cached here
│   ├── express-4.18.2.tgz
│   ├── dotenv-16.3.1.tgz
│   ├── cors-2.8.5.tgz
│   ├── ... (and all transitive dependencies)
├── .yarnrc                             ← Yarn offline config
├── yarn.lock                           ← Lock file
├── node_modules/                       ← Created locally (optional for CF)
├── package.json
├── manifest.yml
└── .cfignore                           ← Configured to upload cache
```

---

## What Gets Uploaded to Cloud Foundry

### ✅ Included (.cfignore allows these)

- `npm-packages-offline-cache/` - The offline package cache
- `.yarnrc` - Yarn offline configuration
- `yarn.lock` - Dependency lock file
- `package.json` - Package manifest
- `src/` - Application source code
- `manifest.yml` - CF deployment config

### ❌ Excluded (.cfignore blocks these)

- `node_modules/` - NOT needed (cache provides deps)
- `.git/` - Git repository
- `Dockerfile` - Docker files
- `*.log` - Log files
- Build scripts and documentation

---

## Key Configuration Files

### .cfignore

```bash
# IMPORTANT: npm-packages-offline-cache is NOT excluded!
# IMPORTANT: .yarnrc is NOT excluded!
# IMPORTANT: yarn.lock is NOT excluded!

# Optional: Exclude node_modules (cache provides dependencies)
node_modules/

# Exclude other unnecessary files
.git/
*.log
Dockerfile
README.md
```

### .gitignore

```bash
# Dependencies (exclude from git)
node_modules/

# Cloud Foundry offline cache (exclude from git)
npm-packages-offline-cache/
.yarnrc
yarn.lock

# Logs
*.log
```

**Note**: The offline cache files are excluded from Git but INCLUDED in Cloud Foundry uploads.

### .yarnrc (created by script)

```
# Created by create-offline-cache.sh
yarn-offline-mirror "./npm-packages-offline-cache"
yarn-offline-mirror-pruning true
```

---

## Automated Deployment

All deployment scripts automatically create the offline cache:

### Simple Demo

```bash
./deploy-default.sh   # Creates cache + deploys blue (1.0.0)
./deploy-blue.sh      # Creates cache + deploys blue
./deploy-green.sh     # Creates cache + deploys green (2.0.0)
```

### DB Demo

```bash
./deploy-default.sh   # Creates cache + deploys
./deploy-blue.sh      # Creates cache + deploys blue
./deploy-green.sh     # Creates cache + deploys green
```

Each script:
1. Runs `./create-offline-cache.sh`
2. Verifies cache was created
3. Runs `cf push`

---

## Verification Checklist

Before deploying, verify:

```bash
# ✓ Offline cache exists
ls npm-packages-offline-cache/
# Should show many .tgz files

# ✓ .yarnrc exists
cat .yarnrc
# Should show offline mirror config

# ✓ yarn.lock exists
ls yarn.lock

# ✓ Check cache size
du -sh npm-packages-offline-cache/
# Typical: 5-30 MB depending on dependencies

# ✓ Count cached packages
ls npm-packages-offline-cache/*.tgz | wc -l
# Should match your dependencies + transitive deps

# ✓ .cfignore configured correctly
grep -E "npm-packages-offline-cache|yarnrc|yarn.lock" .cfignore
# Should NOT find these (they're included by omission)
```

---

## Troubleshooting

### ❌ Error: "Yarn is not installed"

**Solution**: The script will install Yarn automatically, or install manually:

```bash
npm install -g yarn
```

### ❌ Error: "npm-packages-offline-cache not found"

**Cause**: Cache wasn't created

**Solution**:

```bash
./create-offline-cache.sh
ls npm-packages-offline-cache/  # Verify it exists
```

### ❌ Buildpack doesn't use offline mode

**Symptoms**: Buildpack output shows `npm install` or `yarn install` (not offline)

**Cause**: Cache directory not uploaded

**Solution**:

```bash
# Verify .cfignore doesn't exclude the cache
cat .cfignore | grep npm-packages-offline-cache
# Should return NOTHING (cache should be included)

# Recreate cache
./create-offline-cache.sh

# Push again
cf push
```

### ❌ Error: "Cannot find module 'express'" at runtime

**Cause**: Cache incomplete or corrupted

**Solution**:

```bash
# Clean everything
rm -rf npm-packages-offline-cache node_modules .yarnrc yarn.lock

# Recreate cache
./create-offline-cache.sh

# Verify cache has all packages
ls npm-packages-offline-cache/ | wc -l
# Should show many files

# Deploy
cf push
```

### ❌ Database drivers missing (db-demo)

**Cause**: Cache created without database dependencies

**Solution**:

```bash
# Verify package.json has pg and mysql2
cat package.json | grep -E '"pg"|"mysql2"'

# Recreate cache
./create-offline-cache.sh

# Verify drivers are cached
ls npm-packages-offline-cache/ | grep -E "^pg-|^mysql2-"

# Deploy
cf push
```

---

## Dependencies by Demo

### Simple Demo (`simple-demo/nodejs-demo`)

**package.json dependencies**:
- `express` (^4.18.2) - Web framework
- `dotenv` (^16.3.1) - Environment variables
- `cors` (^2.8.5) - CORS middleware

**Typical cache size**: 5-10 MB

**Cached packages**: ~30-40 .tgz files (including transitive dependencies)

### DB Demo (`db-demo/nodejs-demo`)

**package.json dependencies**:
- `express` (^4.21.2) - Web framework
- `pg` (^8.13.1) - PostgreSQL driver
- `mysql2` (^3.11.5) - MySQL driver

**Typical cache size**: 15-30 MB

**Cached packages**: ~50-70 .tgz files (including transitive dependencies)

---

## Updating Dependencies

When you need to update or add dependencies:

```bash
# 1. Update package.json
npm install new-package --save
# or edit package.json manually

# 2. Recreate offline cache
rm -rf npm-packages-offline-cache node_modules .yarnrc yarn.lock
./create-offline-cache.sh

# 3. Test locally
npm start

# 4. Deploy with updated cache
cf push
```

---

## Comparison: Offline Cache vs node_modules Vendoring

| Aspect | npm-packages-offline-cache (Official) | node_modules Vendoring |
|--------|--------------------------------------|------------------------|
| **Official CF Method** | ✅ Yes | ❌ No |
| **Buildpack Support** | ✅ Built-in detection | ⚠️ Relies on detection |
| **Upload Size** | ✅ Smaller (.tgz files) | ❌ Larger (full modules) |
| **Reproducibility** | ✅ yarn.lock ensures exact versions | ⚠️ Depends on package-lock |
| **Setup** | Requires Yarn | Works with npm |
| **CF Documentation** | ✅ Documented | ❌ Not documented |
| **Best Practice** | ✅ Recommended | ⚠️ Workaround |

**Recommendation**: Use `npm-packages-offline-cache` (the official method).

---

## Why Yarn for Offline Mode?

Cloud Foundry's Node.js buildpack uses **Yarn's offline mode** feature, which is designed specifically for air-gapped environments.

**Yarn advantages**:
- Built-in offline mirror feature
- Deterministic dependency resolution
- Flat dependency structure
- Official CF buildpack integration

**You still use npm locally** - Yarn is only used for creating the cache.

---

## Production Best Practices

### 1. Always Use Production Dependencies

The script automatically uses `--production` flag:

```bash
yarn install --production
```

### 2. Verify Cache Before Deploy

```bash
# Quick verification
./create-offline-cache.sh
ls -lh npm-packages-offline-cache/
```

### 3. Test Locally First

```bash
# Create cache
./create-offline-cache.sh

# Test with local node_modules
npm start

# Deploy to CF
cf push
```

### 4. Monitor Cache Size

```bash
# Check size
du -sh npm-packages-offline-cache/

# Optimize if too large
yarn install --production --no-optional
```

---

## Advanced: Manual Cache Creation

For CI/CD pipelines or custom workflows:

```bash
#!/bin/bash
# Minimal offline cache creation

# Configure Yarn
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
yarn config set yarn-offline-mirror-pruning true

# Copy config
cp ~/.yarnrc .

# Clean and install
rm -rf node_modules yarn.lock
yarn install --production

# Verify
ls npm-packages-offline-cache/*.tgz | wc -l
```

---

## Resources

- **Official CF Docs**: https://docs.cloudfoundry.org/buildpacks/node/index.html#vendoring
- **Yarn Offline Mirror**: https://classic.yarnpkg.com/blog/2016/11/24/offline-mirror/
- **Node.js Buildpack**: https://github.com/cloudfoundry/nodejs-buildpack
- **Yarn Documentation**: https://classic.yarnpkg.com/en/docs/

---

## Quick Command Reference

```bash
# Create offline cache
./create-offline-cache.sh

# Manual cache creation
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
yarn config set yarn-offline-mirror-pruning true
cp ~/.yarnrc .
yarn install --production

# Verify cache
ls npm-packages-offline-cache/
du -sh npm-packages-offline-cache/

# Clean and recreate
rm -rf npm-packages-offline-cache node_modules .yarnrc yarn.lock
./create-offline-cache.sh

# Deploy
cf push -f manifest.yml

# View buildpack output
cf logs <app-name> --recent | grep -i offline
```

---

## Success Indicators

When everything is working correctly:

✅ **Cache creation**:
```
✓ Offline cache created successfully!
  Cache directory: npm-packages-offline-cache/
  Cached packages: 45 .tgz files
  Cache size: 12M
```

✅ **Buildpack output**:
```
-----> Detected npm-packages-offline-cache directory
-----> Running yarn in offline mode
```

✅ **Application starts successfully** with no missing module errors

---

**Ready to deploy?**

```bash
cd simple-demo/nodejs-demo  # or db-demo/nodejs-demo
./create-offline-cache.sh
cf push
```

🚀 Your app will deploy without needing external npm registry access!
