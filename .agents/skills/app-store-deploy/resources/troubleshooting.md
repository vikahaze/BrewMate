# Troubleshooting Mac App Store (MAS) Deployments

If you encounter issues during the MAS build and deployment process, check these common error scenarios and solutions:

---

## 1. Missing or Invalid Certificates

### Error Symptoms:
* `Code signing failed: ... Identity '3rd Party Mac Developer Application' not found`
* `Product Archive failed`

### Solutions:
1. Make sure you are using the correct certificates for the Mac App Store. For direct notarization, you use "Developer ID Application", but for App Store packages you must use **"3rd Party Mac Developer Application: Your Name (TeamID)"** and **"3rd Party Mac Developer Installer: Your Name (TeamID)"**.
2. Run this command to check if they are installed in your Keychain:
   ```bash
   security find-identity -v -p codesigning
   ```
3. If they are missing, generate them in your [Apple Developer Account](https://developer.apple.com/) under "Certificates, Identifiers & Profiles", download them, and double-click to add them to your macOS Keychain.

---

## 2. Provisioning Profile Mismatch

### Error Symptoms:
* App crashes instantly when opened locally after a MAS build.
* `Provisioning profile "..." doesn't match bundle identifier "com.app.brewmate"`

### Solutions:
1. Ensure your profile at `.credentials/BrewMate_Distribution.provisionprofile` is downloaded from App Store Connect for the exact Bundle ID (`com.app.brewmate`) and has not expired.
2. If you change your bundle identifier, you must update it in:
   * `package.json`
   * `electron-builder.yml` (`appId`)
   * Regenerate and re-download the provisioning profile from Apple Developer Console.

---

## 3. Entitlements and App Sandbox Issues

### Error Symptoms:
* App opens but cannot make network requests or access files.
* Rejected by Apple review with "App Sandbox not enabled" or "Missing entitlements".

### Solutions:
* Mac App Store apps **MUST** have App Sandbox enabled.
* Verify your entitlements under `build/entitlements.mas.plist` contains:
  ```xml
  <key>com.apple.security.app-sandbox</key>
  <true/>
  ```
* For networking, ensure the following are present in your MAS entitlements:
  ```xml
  <key>com.apple.security.network.client</key>
  <true/>
  ```

---

## 4. `altool` Upload Failures (Error 409 or Authentication Errors)

### Error Symptoms:
* `Error: code -1018 (Authentication failed)`
* `Error: code 409 (Conflict/Duplicate build number)`

### Solutions:
1. **Authentication Failures**: Double-check that your `APPLE_APP_SPECIFIC_PASSWORD` in `.env` is correct. This is *not* your main Apple ID password. It must be generated on [appleid.apple.com](https://appleid.apple.com).
2. **Duplicate Build Number**: Apple does not allow uploading multiple builds with the exact same version number (e.g. `1.0.14`). You must increment the version number in `package.json` before uploading.
3. **Alternative - Transporter**: If `altool` continues to fail, use the Transporter app. The script outputs the built `.pkg` file directly. You can use:
   ```bash
   npm run submit:mas
   ```
   This will open the package directly inside the macOS **Transporter** app, allowing you to sign in visually and upload with a single click.
