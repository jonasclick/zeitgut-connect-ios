# Zeitgut Connect iOS

This folder contains the native iOS app for Zeitgut Connect.

## MSAL Integration

The app uses Microsoft Authentication Library (MSAL) for iOS via Swift Package Manager.

Current package version:
- `MSAL` `2.13.0`

Project facts that must stay aligned:
- Bundle identifier: `com.github.jonasclick.zeitgutconnect`
- Redirect URI: `msauth.com.github.jonasclick.zeitgutconnect://auth`
- Authority: `https://login.microsoftonline.com/common`
- Scope: `api://5363c539-7d42-4566-b2eb-83f636111c20/user_impersonation`
- `LSApplicationQueriesSchemes`: `msauthv2`, `msauthv3`
- Keychain access group: `$(AppIdentifierPrefix)com.microsoft.adalcache`

## App Store Connect dSYM Issue

### Symptom

When archiving and uploading to App Store Connect, Xcode can report:

```text
The archive did not include a dSYM for the MSAL.framework with the UUIDs [...]
```

In this project, the failing UUID was:

```text
058CF611-E3A4-3557-98BB-F0A0D964E7E7
```

### Root Cause

This is not caused by incorrect app auth configuration.
The problem comes from the way MSAL is distributed as a binary Swift package and how Xcode handles dSYMs for that dependency during archive/export.

Important findings from research:
- Microsoft officially supports MSAL via Swift Package Manager.
- Microsoft does not currently document an automatic built-in fix for this App Store Connect dSYM archive issue.
- Microsoft staff and community issue threads currently point to workarounds rather than a library-side automatic solution.
- The issue appears to be in the Xcode/SPM/binary-framework toolchain path, not in our OAuth flow.

Relevant Microsoft and Apple references:
- MSAL README: [github.com/AzureAD/microsoft-authentication-library-for-objc](https://github.com/AzureAD/microsoft-authentication-library-for-objc)
- MSAL iOS/macOS docs: [learn.microsoft.com/en-us/entra/msal/objc/](https://learn.microsoft.com/en-us/entra/msal/objc/)
- MSAL install/configure docs: [learn.microsoft.com/en-us/entra/msal/objc/install-and-configure-msal](https://learn.microsoft.com/en-us/entra/msal/objc/install-and-configure-msal)
- MSAL Swift Package section: [github.com/AzureAD/microsoft-authentication-library-for-objc#using-swift-packages](https://github.com/AzureAD/microsoft-authentication-library-for-objc#using-swift-packages)
- MSAL issue `#2538`: [github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2538](https://github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2538)
- MSAL issue `#2551`: [github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2551](https://github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2551)
- MSAL issue `#2770`: [github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2770](https://github.com/AzureAD/microsoft-authentication-library-for-objc/issues/2770)
- Apple developer forum thread referenced from the MSAL issues: [developer.apple.com/forums/thread/761589](https://developer.apple.com/forums/thread/761589)

## Verified Workaround In This Repo

This repo now contains a verified workaround that makes `xcodebuild archive` succeed and includes the missing MSAL dSYM inside the `.xcarchive`.

### What we do

1. Download the matching MSAL iOS dSYM from the MSAL GitHub release that matches the exact package version.
2. Store that dSYM in the repo under:
   - `Vendor/MSAL/MSAL.framework.dSYM`
3. During archive builds, copy that dSYM into the archive dSYM folder.
4. Before copying, compare the vendored dSYM UUID with the built `MSAL.framework` UUID.
5. Fail the archive if the UUIDs do not match.

### Xcode setup

The workaround is implemented in:
- [Zeitgut Connect.xcodeproj/project.pbxproj](</Users/jonas/proj/zeitgut-connect/zeitgut-connect-ios/Zeitgut Connect.xcodeproj/project.pbxproj>)

The project contains:
- a `Copy MSAL dSYM` Run Script build phase
- declared script input/output paths for the vendored dSYM and copied archive outputs
- `ENABLE_USER_SCRIPT_SANDBOXING = NO` on the app target

The script sandbox had to be disabled for this target because Xcode 26 blocked `dwarfdump` and `ditto` even with declared input/output paths. With sandboxing enabled, archive consistently failed. With sandboxing disabled, archive succeeded.

### Verification

The workaround was verified by running:

```bash
xcodebuild -project 'zeitgut-connect-ios/Zeitgut Connect.xcodeproj' \
  -scheme 'Zeitgut Connect' \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive \
  -archivePath '/tmp/ZeitgutConnect-Test-3.xcarchive'
```

Verified result:
- Archive succeeded
- `/tmp/ZeitgutConnect-Test-3.xcarchive/dSYMs/MSAL.framework.dSYM` exists
- `dwarfdump` on the archived MSAL dSYM returned UUID `058CF611-E3A4-3557-98BB-F0A0D964E7E7`

## Updating MSAL Safely

Whenever MSAL is updated:

1. Check the new version in `Package.resolved`.
2. Download the matching `MSAL-iOS.framework.dSYM.zip` from the same GitHub release.
3. Replace `Vendor/MSAL/MSAL.framework.dSYM`.
4. Re-run an archive build.
5. Confirm the archive contains `MSAL.framework.dSYM`.
6. Confirm the UUID of the vendored dSYM matches the UUID of the built `MSAL.framework`.

Do not reuse an old vendored dSYM after bumping MSAL.

## Notes

- This workaround is intentionally archive-focused and only runs for `Release` + `install`.
- This does not change the app's auth behavior.
- If Microsoft or Apple fixes the underlying binary-package archive behavior later, this workaround can be simplified or removed after verification.
