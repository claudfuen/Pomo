#!/bin/bash
# Create a professional DMG for Pomo distribution

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Creating Pomo.dmg...${NC}"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
DMG_DIR="$BUILD_DIR/dmg"
APP_PATH="$BUILD_DIR/Pomo.app"
DMG_PATH="$BUILD_DIR/Pomo.dmg"
VOLUME_NAME="Pomo"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: Pomo.app not found in build/"
    echo "   Run the build first: xcodebuild -project Pomo.xcodeproj -scheme Pomo -configuration Release build"
    exit 1
fi

# Clean up previous builds
rm -rf "$DMG_DIR"
rm -f "$DMG_PATH"
rm -f "$BUILD_DIR/Pomo-temp.dmg"

# Create DMG directory structure
echo -e "${GREEN}  ✓ Creating DMG structure...${NC}"
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create a temporary DMG
echo -e "${GREEN}  ✓ Creating disk image...${NC}"
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDRW \
    "$BUILD_DIR/Pomo-temp.dmg"

# Mount the DMG
echo -e "${GREEN}  ✓ Configuring DMG appearance...${NC}"
MOUNT_DIR=$(hdiutil attach -readwrite -noverify "$BUILD_DIR/Pomo-temp.dmg" | grep -E '^/dev/' | tail -1 | awk '{print $3}')

# Wait for mount
sleep 2

# Set up the DMG window appearance using AppleScript
osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {100, 100, 640, 480}
        set theViewOptions to icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 100
        
        -- Position the icons
        set position of item "Pomo.app" of container window to {140, 180}
        set position of item "Applications" of container window to {400, 180}
        
        -- Set background color (dark gray)
        set background color of theViewOptions to {5140, 5140, 5654}
        
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Sync and unmount
sync
hdiutil detach "$MOUNT_DIR"

# Convert to compressed DMG
echo -e "${GREEN}  ✓ Compressing DMG...${NC}"
hdiutil convert "$BUILD_DIR/Pomo-temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_PATH"

# Clean up
rm -rf "$DMG_DIR"
rm -f "$BUILD_DIR/Pomo-temp.dmg"

# Show result
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
DMG_BYTES=$(stat -f%z "$DMG_PATH")
echo ""
echo -e "${GREEN}✅ Created: build/Pomo.dmg ($DMG_SIZE)${NC}"
echo ""

# Sign the DMG for Sparkle updates
SIGN_UPDATE="$SCRIPT_DIR/bin/sign_update"
if [ -x "$SIGN_UPDATE" ]; then
    echo -e "${BLUE}🔐 Signing DMG for Sparkle updates...${NC}"
    SIGNATURE=$("$SIGN_UPDATE" "$DMG_PATH" 2>&1 | grep -E '^sparkle:edSignature=' | cut -d'"' -f2)
    
    if [ -n "$SIGNATURE" ]; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}📋 APPCAST UPDATE INFORMATION${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Add this to your appcast.xml <enclosure> tag:"
        echo ""
        echo "  sparkle:edSignature=\"$SIGNATURE\""
        echo "  length=\"$DMG_BYTES\""
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "⚠️  Could not extract signature. Run manually:"
        echo "   $SIGN_UPDATE $DMG_PATH"
    fi
else
    echo -e "${BLUE}ℹ️  To enable Sparkle signing, run:${NC}"
    echo "   ./scripts/generate_sparkle_keys.sh"
    echo ""
    echo "   Then re-run this script to sign the DMG."
fi

echo ""
echo "To test: open $DMG_PATH"

