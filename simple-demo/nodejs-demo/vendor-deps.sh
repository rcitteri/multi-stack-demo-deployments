#!/bin/bash

# vendor-deps.sh - Prepare vendored Node.js dependencies for Cloud Foundry deployment
#
# This script prepares production dependencies for deployment to Cloud Foundry
# environments that cannot access external npm registries during buildpack execution.
#
# Usage: ./vendor-deps.sh

set -e

echo "========================================="
echo "Vendoring Node.js Dependencies"
echo "========================================="

# Clean existing node_modules to ensure fresh install
if [ -d "node_modules" ]; then
    echo "→ Removing existing node_modules..."
    rm -rf node_modules
fi

# Remove package-lock.json for clean state (optional - comment out if you want to keep it)
if [ -f "package-lock.json" ]; then
    echo "→ Removing existing package-lock.json..."
    rm -f package-lock.json
fi

# Install production dependencies only
echo "→ Installing production dependencies..."
npm install --production --no-optional

# Verify node_modules exists
if [ ! -d "node_modules" ]; then
    echo "✗ ERROR: node_modules directory was not created!"
    exit 1
fi

# Count installed packages
PACKAGE_COUNT=$(ls -1 node_modules | wc -l | tr -d ' ')
echo ""
echo "========================================="
echo "✓ Vendoring complete!"
echo "  - $PACKAGE_COUNT packages installed"
echo "  - node_modules size: $(du -sh node_modules | cut -f1)"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Review node_modules to ensure only production deps are present"
echo "  2. Run: cf push -f manifest.yml"
echo "  3. The buildpack will detect vendored dependencies and skip npm install"
echo ""
