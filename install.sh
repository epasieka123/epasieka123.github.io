#!/bin/bash
# Bahamas VAT Tracker - Mac Installer
# Usage: curl -fsSL https://epasieka123.github.io/install.sh | bash

set -e

REPO_BASE="https://raw.githubusercontent.com/epasieka123/epasieka123.github.io/main"
ZIP_URL="$REPO_BASE/BahamasVATTracker-Mac.zip"
INSTALL_DIR="$HOME/Applications/BahamasVATTracker"
TMP_DIR=$(mktemp -d)
APP_NAME="BahamasVATTracker.app"

echo "======================================"
echo " Bahamas VAT Tracker - Installer"
echo "======================================"
echo ""

# 1. Download the zip
echo "Downloading app..."
curl -fsSL "$ZIP_URL" -o "$TMP_DIR/app.zip"

# 2. Unzip it
echo "Extracting..."
unzip -oq "$TMP_DIR/app.zip" -d "$TMP_DIR/extracted"

# 3. Find the .app inside the extracted contents (handles nested folders)
APP_PATH=$(find "$TMP_DIR/extracted" -maxdepth 3 -name "$APP_NAME" -print -quit)
SRC_DIR=$(dirname "$APP_PATH")

if [ -z "$APP_PATH" ]; then
    echo "ERROR: Could not find $APP_NAME inside the downloaded zip."
    exit 1
fi

# 4. Install to fixed location
echo "Installing to: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME"
cp -R "$SRC_DIR/$APP_NAME" "$INSTALL_DIR/"
cp -f "$SRC_DIR/index.html" "$INSTALL_DIR/" 2>/dev/null || true
cp -f "$SRC_DIR/app.js" "$INSTALL_DIR/" 2>/dev/null || true

# 5. Strip quarantine
echo "Removing quarantine flag..."
xattr -cr "$INSTALL_DIR/$APP_NAME" 2>/dev/null || true
xattr -cr "$INSTALL_DIR" 2>/dev/null || true

# 6. Ad-hoc sign
echo "Applying ad-hoc signature..."
codesign --force --deep -s - "$INSTALL_DIR/$APP_NAME" 2>/dev/null || echo "  (codesign skipped)"

# 7. Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "======================================"
echo " Install complete!"
echo " App location: $INSTALL_DIR/$APP_NAME"
echo "======================================"
echo ""

# 8. Launch
open "$INSTALL_DIR/$APP_NAME"
