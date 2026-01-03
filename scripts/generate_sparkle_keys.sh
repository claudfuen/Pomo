#!/bin/bash

# Generate Sparkle EdDSA keys for update signing
# Run this script once to generate your key pair

set -e

echo "🔐 Generating Sparkle EdDSA key pair..."
echo ""

# Find the Sparkle generate_keys binary from DerivedData or checkouts
SPARKLE_BIN=""

# Check DerivedData first (after building in Xcode)
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA" ]; then
    SPARKLE_BIN=$(find "$DERIVED_DATA" -name "generate_keys" -path "*/Sparkle/*" 2>/dev/null | head -1)
fi

# Check SourcePackages (SPM checkouts)
if [ -z "$SPARKLE_BIN" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
    SPARKLE_BIN=$(find "$PROJECT_DIR" -name "generate_keys" 2>/dev/null | head -1)
fi

# Download from Sparkle releases if not found
if [ -z "$SPARKLE_BIN" ] || [ ! -x "$SPARKLE_BIN" ]; then
    echo "📦 Sparkle tools not found locally. Downloading from GitHub..."
    
    TEMP_DIR=$(mktemp -d)
    SPARKLE_VERSION="2.6.4"
    SPARKLE_URL="https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/Sparkle-${SPARKLE_VERSION}.tar.xz"
    
    curl -L "$SPARKLE_URL" -o "$TEMP_DIR/sparkle.tar.xz"
    tar -xf "$TEMP_DIR/sparkle.tar.xz" -C "$TEMP_DIR"
    
    SPARKLE_BIN="$TEMP_DIR/bin/generate_keys"
    SIGN_UPDATE_BIN="$TEMP_DIR/bin/sign_update"
    
    # Copy sign_update to scripts directory for future use
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    mkdir -p "$SCRIPT_DIR/bin"
    cp "$SIGN_UPDATE_BIN" "$SCRIPT_DIR/bin/"
    chmod +x "$SCRIPT_DIR/bin/sign_update"
    echo "✅ Copied sign_update tool to scripts/bin/"
fi

if [ ! -x "$SPARKLE_BIN" ]; then
    echo "❌ Error: Could not find or download generate_keys tool"
    echo "Please build the project in Xcode first, or download Sparkle manually."
    exit 1
fi

echo "Using: $SPARKLE_BIN"
echo ""

# Run generate_keys
"$SPARKLE_BIN"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Copy the PUBLIC key above and paste it into:"
echo "   Pomo/Info.plist → SUPublicEDKey"
echo ""
echo "2. The PRIVATE key is stored in your Keychain."
echo "   Keep it secure! You'll need it to sign releases."
echo ""
echo "3. To sign a release DMG, run:"
echo "   ./scripts/bin/sign_update path/to/Pomo.dmg"
echo ""

