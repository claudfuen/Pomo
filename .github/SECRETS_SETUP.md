# GitHub Secrets Setup for Code Signing

This document explains how to set up the required secrets for automated code signing and notarization.

## Required Secrets

Go to **Settings → Secrets and variables → Actions** in your GitHub repo and add these secrets:

| Secret Name | Description |
|-------------|-------------|
| `DEVELOPER_ID_CERTIFICATE_P12` | Base64-encoded Developer ID certificate |
| `DEVELOPER_ID_CERTIFICATE_PASSWORD` | Password for the P12 certificate |
| `KEYCHAIN_PASSWORD` | Any password for the temporary keychain |
| `DEVELOPER_NAME` | Your name as it appears in the certificate |
| `TEAM_ID` | Your Apple Team ID (10 characters) |
| `APPLE_ID` | Your Apple ID email |
| `APP_SPECIFIC_PASSWORD` | App-specific password for notarization |

---

## Step-by-Step Setup

### 1. Export Your Developer ID Certificate

```bash
# Open Keychain Access, find "Developer ID Application: Your Name"
# Right-click → Export → Save as .p12 with a password

# Convert to base64
base64 -i ~/Desktop/certificate.p12 | pbcopy
```

Paste the copied value as `DEVELOPER_ID_CERTIFICATE_P12`.

### 2. Find Your Team ID

```bash
# Option A: From Xcode
# Xcode → Settings → Accounts → Select team → View Details → Team ID

# Option B: From terminal
security find-identity -v -p codesigning | grep "Developer ID"
# Look for the 10-character code in parentheses
```

### 3. Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → Security → App-Specific Passwords
3. Click "+" to generate a new password
4. Name it "GitHub Actions Notarization"
5. Copy the generated password

### 4. Get Your Developer Name

This is exactly how your name appears in your certificate:

```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
# Example output: "Developer ID Application: John Doe (ABC123XYZ)"
# Your DEVELOPER_NAME is: John Doe
```

---

## Example Values

```
DEVELOPER_ID_CERTIFICATE_P12: MIIKYgIBAzCCCh4GCSq... (long base64 string)
DEVELOPER_ID_CERTIFICATE_PASSWORD: your-p12-password
KEYCHAIN_PASSWORD: any-random-password-here
DEVELOPER_NAME: Claudio Fuentes
TEAM_ID: ABC123XYZ
APPLE_ID: your@email.com
APP_SPECIFIC_PASSWORD: xxxx-xxxx-xxxx-xxxx
```

---

## Creating a Release

Once secrets are configured, create a release by pushing a tag:

```bash
git tag v1.0.1
git push origin v1.0.1
```

The workflow will automatically:
1. Build the app
2. Sign with your Developer ID
3. Notarize with Apple
4. Create a signed DMG
5. Publish to GitHub Releases

---

## Troubleshooting

### "No identity found"
- Ensure the certificate is a "Developer ID Application" certificate (not iOS Distribution)
- Verify the base64 encoding is correct

### "Unable to notarize"
- Check that the App-Specific Password is correct
- Ensure 2FA is enabled on your Apple ID
- Verify the Team ID matches your Developer account

### "Code signature invalid"
- Make sure `--options runtime` is included for hardened runtime
- Check that all frameworks/binaries are signed

