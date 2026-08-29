#!/bin/bash

# BrewMate MAS Deploy Script
# This script automates the versioning, building, and uploading of BrewMate to the Mac App Store / TestFlight.

set -e

# Load environment variables
if [ -f .env ]; then
  # Load specific variables from .env
  APPLE_ID=$(grep "^APPLE_ID=" .env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
  APPLE_APP_SPECIFIC_PASSWORD=$(grep "^APPLE_APP_SPECIFIC_PASSWORD=" .env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
else
  echo "❌ .env file not found. Please ensure it exists and contains APPLE_ID and APPLE_APP_SPECIFIC_PASSWORD."
  exit 1
fi

if [ -z "$APPLE_ID" ] || [ -z "$APPLE_APP_SPECIFIC_PASSWORD" ]; then
  echo "❌ APPLE_ID or APPLE_APP_SPECIFIC_PASSWORD missing in .env."
  exit 1
fi

# Get current version
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "📦 Current package version: $CURRENT_VERSION"

# Determine target version & configure auto-bump behavior
if [ -n "$1" ]; then
  NEW_VERSION=$1
  echo "🚀 Targeted specific version: $NEW_VERSION"
  
  # Update package.json to requested version
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.version = '$NEW_VERSION';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  "
  echo "✅ Updated package.json version to: $NEW_VERSION"
  
  # Tell build script to skip its own increment logic
  export SKIP_VERSION_BUMP="true"
else
  # No version provided; let scripts/build-mas-universal.sh handle automatic patch increment
  export SKIP_VERSION_BUMP="false"
  
  # Pre-calculate the bumped version for search patterns
  IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
  NEW_VERSION="$major.$minor.$((patch + 1))"
  echo "🚀 Deploying with automatic patch version bump (targeting: $NEW_VERSION)"
fi

# Run the native MAS build script
echo ""
echo "🛠 Triggering Mac App Store universal build..."
npm run build:mas

# Find the generated PKG in dist-app/
echo ""
echo "🔍 Searching for generated PKG file..."
PKG_FILE=$(find dist-app -name "BrewMate-*.pkg" -type f | head -n 1)

if [ -z "$PKG_FILE" ] || [ ! -f "$PKG_FILE" ]; then
  echo "❌ Could not find any generated PKG file in dist-app/."
  exit 1
fi

PKG_NAME=$(basename "$PKG_FILE")
echo "✅ Found package: $PKG_NAME"
echo "   Path: $PKG_FILE"
echo ""

# Upload to TestFlight
echo "☁️ Uploading to TestFlight / App Store Connect..."
xcrun altool --upload-app --type macos --file "$PKG_FILE" --username "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --verbose

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  🎉 DEPLOYMENT OF $NEW_VERSION INITIATED SUCCESSFULLY!"
echo "═══════════════════════════════════════════════════════════════"
echo "Check progress on App Store Connect:"
echo "https://appstoreconnect.apple.com/"
echo "═══════════════════════════════════════════════════════════════"
