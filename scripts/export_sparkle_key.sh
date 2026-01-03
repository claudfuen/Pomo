#!/bin/bash

# Export Sparkle EdDSA private key from Keychain for use in GitHub Secrets
# Run this once to get the key, then add it to your repo's secrets

set -e

echo "🔐 Exporting Sparkle private key from Keychain..."
echo ""

# The key is stored in Keychain with this service name
SERVICE_NAME="https://sparkle-project.org"
ACCOUNT_NAME="ed25519"

# Export the key
PRIVATE_KEY=$(security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w 2>/dev/null)

if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: Could not find Sparkle private key in Keychain"
    echo ""
    echo "Make sure you've run ./scripts/generate_sparkle_keys.sh first"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 GITHUB SECRETS SETUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to: https://github.com/claudfuen/Pomo/settings/secrets/actions"
echo ""
echo "2. Click 'New repository secret'"
echo ""
echo "3. Name: SPARKLE_PRIVATE_KEY"
echo ""
echo "4. Value (copy everything between the lines):"
echo ""
echo "────────────────────────────────────────────────────────────"
echo "$PRIVATE_KEY"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "⚠️  Keep this key SECRET! Never commit it to your repo."
echo ""


